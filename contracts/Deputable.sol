pragma solidity ^0.4.21;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

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