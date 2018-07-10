pragma solidity ^0.4.24;


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
    // mapping of user addresses to array of their certificates
    mapping (address => Certificate[]) certificates;

    // Structure represents a single certificate metadata
    // Size: 32x3 = 96 bytes
    struct Certificate {
        // SHA256 hash of the certificate itself, used for validation of the certificate 
        // by the Issuer once they receive it from the User
        bytes32 certificateHash; // 32 bytes

        address issuer; // 20 bytes

        bool revoked; // 1 byte
    }

    // Address of Issuers contract
    Issuers public issuersContract;

    // Owner and deputy can modify Issuers contract address (for upgrades etc)
    function setIssuersContract(Issuers _issuersContract) public onlyOwnerOrDeputy {
        issuersContract = Issuers(_issuersContract);
    }

    event LogAddCertificate(address indexed _userAddress, address indexed _issuerAddress, bytes32 _certificateHash);

    // Constructor
    constructor(Issuers _issuersContract) public {
        issuersContract = _issuersContract; 
    }

    // For debugging
    function whoami() public view returns (address) {
        return msg.sender;
    }
  
    function addCertificate(address _userAddress, bytes32 _certificateHash) public
        returns(bool success) 
    {
        // Make sure the sender if a registered issuer
        address issuerAddress = msg.sender;
        require(issuersContract.getIssuerStatus(issuerAddress) == Issuers.IssuerStatus.Active); // require an active issuer

        // Create the Certificate object
        Certificate memory cert = Certificate({
            certificateHash: _certificateHash,
            issuer: issuerAddress,
            revoked: false
        });

        certificates[_userAddress].push(cert);

        emit LogAddCertificate(_userAddress, issuerAddress, _certificateHash);
        
        return true;
    }

    function getCertificateMetadata(address _userAddress, bytes32 _certificateHash) public view
        returns (address _issuer, bool _revoked) {
        
        // Get certificates array
        Certificate[] storage certs = certificates[_userAddress];

        int i = getCertificateIndex(_userAddress, _certificateHash);

        if (i >= 0) {
            _issuer = certs[uint(i)].issuer;
            _revoked = certs[uint(i)].revoked;
        }

        // In case the cert not found, initial values will be returned, so the client should verify 
        // that the return values are not initial ones. 
    }

    // We need teh following two methods to be able to retrieve all certificate matadadat for a user
    function getCertificateCount(address _user) public view returns(uint256) {
        return certificates[_user].length;
    }

    function getCertificateAt(address _user, uint _index) public view 
        returns(bytes32 certificateHash, address issuer, bool revoked) {
        
        Certificate storage cert = certificates[_user][_index];

        certificateHash = cert.certificateHash;
        issuer = cert.issuer;
        revoked = cert.revoked;
    }

    function getCertificateIndex(address _user, bytes32 _certificateHash) public view returns (int) {
        Certificate[] storage certs = certificates[_user];

        // Find certificate with certificateHash
        uint count = certs.length;

        for (uint i = 0; i < count; i++) {
            if (certs[i].certificateHash == _certificateHash) {
                return int(i);
            }
        }

        return -1;
    }

    event LogCertificateRevoked(address indexed _userAddress, bytes32 _certificateHash);

    //Revoke a certificate - only the issuer can revoke
    function revokeCertificate(address _user, uint certificateIndex) public {
        address issuer = msg.sender;

        Certificate storage cert = certificates[_user][certificateIndex];

        require(issuer == cert.issuer, "Only a certificate issuer can revoke their certificate");

        cert.revoked = true;

        emit LogCertificateRevoked(_user, cert.certificateHash);
    }
}
