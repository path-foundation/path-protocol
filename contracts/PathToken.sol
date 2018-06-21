pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "openzeppelin-solidity/contracts/ownership/HasNoEther.sol";
import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "./token/TransferAndCallback.sol";

/**
    PathToken is a standard ERC20 token with additional transfer function 
    that notifies the receiving contract of the transfer.
 */
contract PathToken is StandardToken, TransferAndCallback, Claimable, CanReclaimToken, HasNoEther {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public {
        name = "Path Token";
        symbol = "PATH";
        decimals = 6;
        totalSupply_ = 500000000 * 10 ** uint(decimals);
        balances[owner] = totalSupply_;
    }
}