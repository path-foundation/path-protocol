pragma solidity ^0.4.23;

import "./Deputable.sol";

import "./Issuers.sol";

/**
    This smart contract is used for storing Certificate information used for certificate validation.
    It doesn't store the certificate itself.

    Certificates are issued by Issuers. Below if the overall architecture,
    but only a part of it is on chain. Transfer of the certificate itself 
    between Issuer and User is off chain and can be implemented various ways
    depending on the Issuer and User client apps.
 */

contract Certificates is Deputable {
    // Structure represents a single certificate metadata
    // Size: 32x3 = 96 bytes
    struct Certificate {
        // SHA256 hash of the certificate itself, used for validation of the certificate 
        // by the Issuer once they receive it from the User
        bytes32 certificateHash; // 32 bytes

        // sha256 of the certificate id, eg sha("AWS Associate Developer - John Smith, 02/02/2018")
        // should be unique for an issuer but the exact format of the title can be defined by the Issuer's client app
        bytes32 certificateId; // 32 bytes

        // Certificate Issuer's address
        address issuer; // 20 bytes

        // Certificate expiration date, optional
        uint96 expiresOn; // 12 bytes
    }

    struct User {
        // User's index in users array
        uint index; 
        // User's certificates
        Certificate[] certificates;
    }

    // Address of Issuers contract
    Issuers private issuersContract;

    // Owner and deputy can modify Issuers contract address (for upgrades etc)
    function setIssuersContract(Issuers _issuersContract) public onlyOwnerOrDeputy {
        issuersContract = Issuers(_issuersContract);
    }

    function getIssuersContract() public view returns(Issuers) {
        return issuersContract;
    }
  
    mapping(address => User) private users;
    address[] private userIndex;

    event LogAddCertificate(address indexed _userAddress, bytes32 _certificateId);

    // Constructor
    constructor(Issuers _issuersContract) public {
        issuersContract = _issuersContract; 
    }

    // For debugging
    function whoami() public view returns (address) {
        return msg.sender;
    }
  
    function isUser(address userAddress) public view returns(bool) {
        if (userIndex.length == 0) 
            return false;

        return (userIndex[users[userAddress].index] == userAddress);
    }

    // We don't need to expose this method as adding a user
    // without a certificate doesn't make sense
    function addUser(address _userAddress) internal returns(uint index) {
        users[_userAddress].index = uint48(userIndex.push(_userAddress)) - 1;

        return userIndex.length - 1;
    }
  
    function getUserIndex(address _userAddress) public view returns(uint index) {
        require(isUser(_userAddress));

        return(users[_userAddress].index);
    } 

    function getUserAtIndex(uint index) public view returns(address userAddress) {
        require(index < getUserCount());

        return userIndex[index];
    }
  
    function addCertificate(address _userAddress, bytes32 _certificateHash, bytes32 _certificateId, uint48 _expiresOn) public
        returns(bool success) 
    {
        // Make sure the sender if a registered issuer
        address issuer = msg.sender;
        require(issuersContract.getIssuerStatus(issuer) == Issuers.IssuerStatus.Active); // require an active issuer

        // Add user if doesn't exist
        if (!isUser(_userAddress)) {
            addUser(_userAddress);
        }

        // Create the Certificate object
        Certificate memory cert = Certificate({
            certificateHash: _certificateHash,
            certificateId: _certificateId,
            issuer: issuer,
            expiresOn: _expiresOn
        });

        users[_userAddress].certificates.push(cert);

        emit LogAddCertificate(_userAddress, _certificateId);
        
        return true;
    }

    function getCertificate(address _userAddress, bytes32 _certificateId) public view
        returns (bytes32 _certHash, address _issuer, uint96 _expiresOn) {
        // Make sure user exists
        require(isUser(_userAddress));

        // Get certificates array
        Certificate[] storage certs = users[_userAddress].certificates;

        // Find certificate with certificateId
        uint count = getCertificateCount(_userAddress);
        for (uint i = 0; i < count; i++) {
            if (certs[i].certificateId == _certificateId) {
                _certHash = certs[i].certificateHash;
                _issuer = certs[i].issuer;
                _expiresOn = certs[i].expiresOn;
            }
        }

        // In case the cert not found, initial values will be returned, so teh client should verify 
        // that the return values are not initial ones. 
    }

    function getCertificateCount(address userAddress) public view returns(uint count) {
        require(isUser(userAddress));

        return users[userAddress].certificates.length;
    }

    function getUserCount() public view returns(uint count) {
        return userIndex.length;
    }
}
