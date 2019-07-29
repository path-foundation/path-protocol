pragma solidity ^0.5.1;

import "./TransferAndCallbackInterface.sol";
import "./TransferAndCallbackReceiver.sol";

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract TransferAndCallback is ERC20Basic, TransferAndCallbackInterface {

/**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `balanceTransferred` function if the recipient is a contract.
     *      The token transfer fails if the recipient is NOT a contract
    *       or is a contract but does not implement the `balanceTransferred` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transferAndCallback(address _to, uint256 _value, bytes memory _data) public returns(bool) {
        // First make sure that _to address is a contract
        uint256 codeLength;
        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            codeLength := extcodesize(_to)
        }

        require(codeLength > 0, "'_to' address must be a contract");

        // transfer funds
        transfer(_to, _value);

        TransferAndCallbackReceiver receiver = TransferAndCallbackReceiver(_to);
        receiver.balanceTransferred(msg.sender, _value, _data);

        return true;
    }
}