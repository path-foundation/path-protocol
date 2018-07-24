pragma solidity ^0.4.24;

import "./Deputable.sol";
import "./Issuers.sol";

/**
    This smart contract is used for storing Certificate information used for certificate validation.
    It doesn't store the certificate itself.
 */

contract Certificates is Deputable {
    // mapping of user addresses to array of their certificates
    mapping (address => Certificate[]) certificates;

    // Array of all users in the system
    address[] users;

    // Structure represents a single certificate metadata
    // Size: 32x2 = 64 bytes
    struct Certificate {
        // SHA256 hash of the certificate itself, used for validation of the certificate 
        // by the Seeker once they receive it from the User
        // This hash is also used as the certificate id
        bytes32 hash; // 32 bytes

        address issuer; // 20 bytes

        // Issuer has control over certificates issued by them - they can revoke them
        // For example, if they found that a user was cheating on a test etc.
        bool revoked; // 1 byte
    }

    // Address of Issuers contract
    // We need this for whitelisting issuers
    Issuers public issuersContract;

    // Owner and deputy can modify Issuers contract address (for upgrades etc)
    function setIssuersContract(Issuers _issuersContract) public onlyOwnerOrDeputy {
        issuersContract = Issuers(_issuersContract);
    }

    event LogAddCertificate(address indexed _user, address indexed _issuerAddress, bytes32 _hash);

    // Constructor
    constructor(Issuers _issuersContract) public {
        issuersContract = _issuersContract; 
    }

    function addCertificate(address _user, bytes32 _hash) public
    {
        // Make sure the sender if a registered issuer
        address issuer = msg.sender;

        // Add user to users array if it's the first certificate for the user
        if (certificates[_user].length == 0) {
            users.push(_user);
        }

        // require an active issuer
        require(issuersContract.getIssuerStatus(issuer) == Issuers.IssuerStatus.Active);

        // Create the Certificate object
        Certificate memory cert = Certificate({
            hash: _hash,
            issuer: issuer,
            revoked: false
        });

        certificates[_user].push(cert);

        emit LogAddCertificate(_user, issuer, _hash);
    }

    // Retrieve certificate metadata
    // If the certificate with the provided user address and hash doesn't exist,
    // then the return value _issuer will be 0x0
    function getCertificateMetadata(address _user, bytes32 _hash) public view
        returns (address _issuer, bool _revoked) {
        
        // Get certificates array
        Certificate[] storage certs = certificates[_user];

        int i = getCertificateIndex(_user, _hash);

        if (i >= 0) {
            _issuer = certs[uint(i)].issuer;
            _revoked = certs[uint(i)].revoked;
        }
    }

    // We need the following two methods to be able to retrieve all certificate matadadat for a user
    function getCertificateCount(address _user) public view returns(uint256) {
        return certificates[_user].length;
    }

    function getCertificateAt(address _user, uint _index) public view 
        returns(bytes32 hash, address issuer, bool revoked) {
        
        Certificate[] storage certs = certificates[_user];

        if (certs.length > _index) {
            Certificate storage cert = certificates[_user][_index];

            hash = cert.hash;
            issuer = cert.issuer;
            revoked = cert.revoked;
        }
    }

    function getCertificateIndex(address _user, bytes32 _hash) public view returns (int) {
        Certificate[] storage certs = certificates[_user];

        // Find certificate by hash
        uint count = certs.length;

        for (uint i = 0; i < count; i++) {
            if (certs[i].hash == _hash) {
                return int(i);
            }
        }

        return -1;
    }

    event LogCertificateRevoked(address indexed _user, bytes32 _hash);

    //Revoke a certificate - only the issuer can revoke
    function revokeCertificate(address _user, uint certificateIndex) public {
        address issuerAddress = msg.sender;

        // require an active issuer
        require(issuersContract.getIssuerStatus(issuerAddress) == Issuers.IssuerStatus.Active);

        Certificate storage cert = certificates[_user][certificateIndex];

        require(issuerAddress == cert.issuer, "Only a certificate issuer can revoke their certificate");

        cert.revoked = true;

        emit LogCertificateRevoked(_user, cert.hash);
    }
}
