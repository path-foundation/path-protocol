pragma solidity ^0.4.24;

/**
    Declares an interface for functionality allowing to notify the receiving contract 
    of the transfer of tokens or approval.
 */

contract TransferAndCallbackInterface {
    function transferAndCallback(address _to, uint256 _value, bytes _data) public returns (bool);
}