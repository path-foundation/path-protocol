pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


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
        require(msg.sender == owner || msg.sender == deputy);
        _;
    }
}