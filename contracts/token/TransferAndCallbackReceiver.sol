pragma solidity ^0.4.24;

/**
 * An interface for a contract that receives tokens and gets notified after the transfer
 */
contract TransferAndCallbackReceiver { 
/**
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function balanceTransferred(address _from, uint256 _value, bytes _data) public;
}