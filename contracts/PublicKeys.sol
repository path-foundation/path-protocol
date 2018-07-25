pragma solidity ^0.4.24;

// Contract stores a map of ethereum addresses and their associated public keys
contract PublicKeys {
    mapping (address => bytes) public publicKeyStore;

    // Method adds a public key for the caller address
    // after verifying that the sender's address derives from that public key
    function addPublicKey(bytes _publicKey) public {
        // Make sure the sender sends their own public key
        require(address(keccak256(_publicKey)) == msg.sender);
        publicKeyStore[msg.sender] = _publicKey;
    }
}