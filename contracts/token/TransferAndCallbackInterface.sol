pragma solidity ^0.5.1;

/**
    Declares an interface for functionality allowing to notify the receiving contract
    of the transfer of tokens or approval.
 */

contract TransferAndCallbackInterface {
    function transferAndCallback(address _to, uint256 _value, bytes memory _data) public returns (bool);
}