pragma solidity ^0.5.1;

/**
    This contract is used in testing PathToken' TransferAndCallback functionality
 */

import "../token/TransferAndCallbackReceiver.sol";

contract ContractWithCallback is TransferAndCallbackReceiver {
    address public approvedToken;

    constructor (address _approvedToken) public {
        approvedToken = _approvedToken;
    }

    address public user;
    bytes32 public seekerPublicKey;
    bytes32 public certificateId;

    // Here we receive additional data as bytes type
    // and unpack into expected variables
    function balanceTransferred(address, uint256, bytes memory _data) public {
        require(msg.sender == approvedToken, "Sender is not an approved token");

        uint256 btsptr;
        address _user;
        bytes32 _seekerPublicKey;
        bytes32 _certificateId;

        // We need to unpack (address _user, bytes32 _seekerPublicKey, bytes32 certificateId)
        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            btsptr := add(_data, /*BYTES_HEADER_SIZE*/32)
            _user := mload(btsptr)
            btsptr := add(_data, /*BYTES_HEADER_SIZE*/64)
            _seekerPublicKey := mload(btsptr)
            btsptr := add(_data, /*BYTES_HEADER_SIZE*/96)
            _certificateId := mload(btsptr)
        }

        user = _user;
        seekerPublicKey = _seekerPublicKey;
        certificateId = _certificateId;
    }
}