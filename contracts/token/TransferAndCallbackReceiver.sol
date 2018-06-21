pragma solidity ^0.4.24;

 /**
 * @title Contract that will work with ERC223 tokens.
 */
 
contract TransferAndCallbackReceiver { 
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function balanceTransferred(address _from, uint256 _value, bytes _data) public;
}