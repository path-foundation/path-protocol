
// File: contracts/Ownable.sol

pragma solidity ^0.5.1;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "Message sender is not contract Owner");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Unable to change the Owner to 0x0 address");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Deputable.sol

pragma solidity ^0.5.1;


/// @title Deputable
/// @author Path Foundation
/// @notice The Deputable contract is an extension of Ownable contract that adds a deputy address.
/// @dev In general, deputy would have the same permissions as the owner, except that it can't change the owner
contract Deputable is Ownable {
    address public deputy;

    event DeputyModified(address indexed previousDeputy, address indexed newDeputy);

    /// @notice Set a new deputy
    /// @dev Only the contract owner or the current deputy can reassign the depity to someone else
    function setDeputy(address _deputy) public onlyOwnerOrDeputy {
        emit DeputyModified(deputy, _deputy);
        deputy = _deputy;
    }

    modifier onlyOwnerOrDeputy() {
        require(msg.sender == owner || msg.sender == deputy, "Only owner or deputy may execute the function");
        _;
    }
}

// File: contracts/Issuers.sol

pragma solidity ^0.5.1;


/// @title Stores certificate issuers
/// @dev Only the Owner or a Deputy can add/enable/disable an issuer
/// @author Path Foundation
contract Issuers is Deputable {
    // Whitelist of issuers mapped to their status
    mapping(address => IssuerStatus) internal issuers;

    enum IssuerStatus { None, Active, Inactive }

    event LogIssuerAdded(address indexed _issuer);

    /// @notice Add a new active issuer or reactivate inactive user
    function addIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);

        if (status != IssuerStatus.Active) {
            issuers[_issuerAddress] = IssuerStatus.Active;
            emit LogIssuerAdded(_issuerAddress);
        }
    }

    event LogIssuerRemoved(address indexed _issuerAddress);

    /// @notice Deactivate an active issuer
    /// @dev If the issuer does not exist or is inacive, no exceptions thrown
    function removeIssuer(address _issuerAddress) public onlyOwnerOrDeputy {
        IssuerStatus status = getIssuerStatus(_issuerAddress);

        if (status == IssuerStatus.Active) {
            issuers[_issuerAddress] = IssuerStatus.Inactive;
            emit LogIssuerRemoved(_issuerAddress);
        }
    }

    /// @notice Method returns issuer status
    /// @dev Status:
    /// 0 - issuer doesnt exists/not registered
    /// 1 - issuer is active
    /// 2 - issuer is inactive/deactivated
    function getIssuerStatus(address _issuerAddress) public view returns (IssuerStatus) {
        return issuers[_issuerAddress];
    }
}
