const {
    artifacts,
    contract,
    assert,
} = global;

const Escrow = artifacts.require('Escrow');
const PathToken = artifacts.require('PathToken');
const Certificates = artifacts.require('Certificates');
const keys = require('./util/keys');

const { publicKey, address } = keys.generateKeys(1);

contract('Escrow', async (accounts) => {
    const [
        owner,
        user1,
        user2,
        seeker1,
        seeker2,
        issuer1,
        issuer2
    ] = accounts;

    let token,
        certificates,
        instance;

    before(async () => {
        token = await PathToken.new();
        certificates = await Certificates.new();
        instance = await Escrow.new(token.address, certificates.address);
        // Load data, move some tokens to seekers
    });
});
