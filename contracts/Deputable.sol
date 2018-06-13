pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Deputable
 * @dev The Deputable contract is an extension of Ownable contract that adds a deputy address
 * In general, deputy would have the same permissions as the owner, except that it can't change the owner
 */
contract Deputable is Ownable {
    address public deputy;
    event DeputyModified(address indexed previousDeputy, address indexed newDeputy);

    // Current deputy can reassign depity to someone else
    function setDeputy(address _deputy) public onlyOwnerOrDeputy {
        emit DeputyModified(deputy, _deputy);
        deputy = _deputy;
    }

    modifier onlyOwnerOrDeputy() {
        require(msg.sender == owner || msg.sender == deputy);
        _;
    }
}