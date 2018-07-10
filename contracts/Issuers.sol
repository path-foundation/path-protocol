pragma solidity ^0.4.24;

import "./Deputable.sol";

/*
    Contracts stores and manages certificate issuers
    Only the Owner or a Deputy can add/enable/disable an issuer
    Anyone can read the Issuers
 */
contract Issuers is Ownable, Deputable {
    struct Issuer {
        address id;
        bytes32 name;
        IssuerStatus status;
        uint index; 
    }

    enum IssuerStatus { None, Active, Inactive }

    uint public countActiveIssuers;

    mapping(address => Issuer) internal issuers;
    address[] issuersIndex; 

    // Method retruns caller's address. 
    function whoami() public view returns (address) {
        return msg.sender;
    }

    enum AddIssuerStatus { Success, AlreadyExists }
    event LogAddIssuer(address indexed _address, AddIssuerStatus _status);
    
    // Add a new active issuer; do nothing if exists
    function addIssuer(address _issuerAddress, bytes32 issuerName) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);
        if (status == IssuerStatus.None) {
            uint index = issuersIndex.push(_issuerAddress) - 1;
            issuers[_issuerAddress] = Issuer({ id: _issuerAddress, name: issuerName, status: IssuerStatus.Active, index: index });
            countActiveIssuers++;
            emit LogAddIssuer(_issuerAddress, AddIssuerStatus.Success);
        } else if (status == IssuerStatus.Inactive) {
            Issuer storage issuer = issuers[_issuerAddress];
            issuer.name = issuerName;
            issuer.status = IssuerStatus.Active;
            countActiveIssuers++;
            emit LogAddIssuer(_issuerAddress, AddIssuerStatus.Success);
        } else {
            emit LogAddIssuer(_issuerAddress, AddIssuerStatus.AlreadyExists);
        }
    }

    enum RemoveIssuerStatus { Success, NotFound, AlreadyInactive }
    event LogRemoveIssuer(address indexed _issuerAddress, RemoveIssuerStatus _status);

    function removeIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);
        if (status == IssuerStatus.Active) {
            Issuer storage issuer = issuers[_issuerAddress];
            issuer.status = IssuerStatus.Inactive;
            countActiveIssuers--;
            emit LogRemoveIssuer(_issuerAddress, RemoveIssuerStatus.Success);
        } else if (status == IssuerStatus.Inactive) {
            emit LogRemoveIssuer(_issuerAddress, RemoveIssuerStatus.AlreadyInactive);
        } else /*if (status == IssuerStatus.None)*/ {
            emit LogRemoveIssuer(_issuerAddress, RemoveIssuerStatus.NotFound);
        }
    }

    // Method returns issuer at specified index, or 0 is issuer doesn't exist
    function getIssuerAtIndex(uint index) public view returns (address, bytes32, IssuerStatus) {
        Issuer storage issuer = issuers[issuersIndex[index]];
        return (issuer.id, issuer.name, issuer.status);
    }

    // Method returns issuer status
    // 0 - issuer doesnt exists/not registered
    // 1 - issuer is active
    // 2 - issuer is inactive/deactivated
    function getIssuerStatus(address _issuerAddress) public view returns (IssuerStatus) {
        Issuer storage issuer = issuers[_issuerAddress];
        return issuer.status;
    }

    //function getIssuerStatusInt(address _issuerAddress)

    // Method returns the total number of issuers in the system, including inactive
    function getTotalIssuersCount() public view returns (uint) {
        return issuersIndex.length;
    }
}