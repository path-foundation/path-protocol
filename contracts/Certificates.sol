pragma solidity ^0.4.24;

import "./Deputable.sol";
import "./Issuers.sol";

/// @title The store of certificate hashes per user
/// @author Path Foundation
/// @notice The contract is used by Issuers when submitting certificates and 
/// by Seekers when verifying a certificate received from a User
contract Certificates is Deputable {
    /// @notice mapping of user addresses to array of their certificates
    mapping (address => Certificate[]) certificates;

    /// @title Array of all user addresses in the system
    address[] public users;

    /// @title Structure represents a single certificate metadata
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

    /// @notice Title Address of Issuers contract.
    /// We use this for getting whitelisted issuers
    Issuers public issuersContract;

    // Constructor
    constructor(Issuers _issuersContract) public {
        issuersContract = _issuersContract; 
    }

    /// @notice Owner and deputy can modify Issuers contract address (for upgrades etc)
    /// @dev Can only be called by contract owner or deputy
    /// @param _issuersContract Issuers Address of Issuers contract
    function setIssuersContract(Issuers _issuersContract) public onlyOwnerOrDeputy {
        issuersContract = Issuers(_issuersContract);
    }

    event LogAddCertificate(address indexed _user, address indexed _issuerAddress, bytes32 _hash);

    /// @notice Add a certificate
    /// @dev Can only be called by active issuers (addresses in Issuers contract with status = Active)
    /// @param _user address of certificate owner
    /// @param _hash sha256 hash of the certificate text
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

    /// @notice Retrieve certificate metadata
    /// @dev If the certificate with the provided user address and hash doesn't exist,
    /// then the return value of `_issuer` will be `0x0`
    /// @param _user User address
    /// @param _hash Sha256 hash of the certificate to retrieve metadata for
    /// @return _issuer Address of the certificate issuer
    /// @return _revoked Flag showing whether the certificate has been revoked by its issuer
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

    /// @notice Method returns the number of certificates for a given user
    /// @param _user User address
    /// @return count Number of certificates a given user has
    function getCertificateCount(address _user) public view returns(uint256 count) {
        count = certificates[_user].length;
    }

    /// @notice Get metadata of a user's certificate by its index
    /// @param _user User's address
    /// @param _index Certificate index
    /// @return hash Certificate hash
    /// @return _issuer Address of the certificate issuer
    /// @return _revoked Flag showing whether the certificate has been revoked by its issuer
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

    /// @notice Find index of a user's certificate by its hash
    /// @param _user User's address
    /// @param _hash Certificate hash
    /// @return index Indexof the certificate in the user's certificates array
    function getCertificateIndex(address _user, bytes32 _hash) public view returns (int index) {
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

    /// @notice Revoke a certificate
    /// @dev Only the issuer can revoke their own certificate
    /// @param _user User address
    /// @param _certificateIndex Index of certificate to be revoked in the user's array of certificates
    function revokeCertificate(address _user, uint _certificateIndex) public {
        address issuerAddress = msg.sender;

        // require an active issuer
        require(issuersContract.getIssuerStatus(issuerAddress) == Issuers.IssuerStatus.Active);

        Certificate storage cert = certificates[_user][_certificateIndex];

        require(issuerAddress == cert.issuer, "Only a certificate issuer can revoke their certificate");

        cert.revoked = true;

        emit LogCertificateRevoked(_user, cert.hash);
    }
}
