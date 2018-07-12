pragma solidity ^0.4.24;

import "./Deputable.sol";

/*
    Contracts stores and manages certificate issuers
    Only the Owner or a Deputy can add/enable/disable an issuer
    Anyone can read the Issuers
 */
contract Issuers is Deputable {
    // Whitelist of issuers mapped to their status
    mapping(address => IssuerStatus) internal issuers;

    enum IssuerStatus { None, Active, Inactive }

    event LogIssuerAdded(address indexed _issuer);
    
    // Add a new active issuer or reactivate inactive user
    function addIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);

        if (status != IssuerStatus.Active) {
            issuers[_issuerAddress] = IssuerStatus.Active;
            emit LogIssuerAdded(_issuerAddress);
        }
    }

    event LogIssuerRemoved(address indexed _issuerAddress);

    function removeIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);

        if (status == IssuerStatus.Active) {
            issuers[_issuerAddress] = IssuerStatus.Inactive;
            emit LogIssuerRemoved(_issuerAddress);
        } 
    }

    // Method returns issuer status
    // 0 - issuer doesnt exists/not registered
    // 1 - issuer is active
    // 2 - issuer is inactive/deactivated
    function getIssuerStatus(address _issuerAddress) public view returns (IssuerStatus) {
        return issuers[_issuerAddress];
    }
}