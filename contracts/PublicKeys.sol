pragma solidity ^0.5.1;

/// @title Contract stores a map of ethereum addresses and their associated public keys
contract PublicKeys {
    mapping (address => bytes) public publicKeyStore;

    /// @notice Adds a public key for the caller address
    /// after verifying that the sender's address derives from that public key
    function addPublicKey(bytes memory _publicKey) public {
        // Make sure the sender sends their own public key
        require(address(uint160(uint256(keccak256(_publicKey)))) == msg.sender, "Sender's address doesn't match the public key");
        publicKeyStore[msg.sender] = _publicKey;
    }
}