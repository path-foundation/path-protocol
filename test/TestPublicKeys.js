const {
    artifacts,
    contract,
    assert,
} = global;

const { generateAddressesFromSeed } = require('./util/keys');

const PublicKeys = artifacts.require('PublicKeys');

const pk = {};
generateAddressesFromSeed(process.env.TEST_MNEMONIC, 10)
    .forEach(key => { pk[key.address] = { public: key.publicKey, private: key.privateKey }; });

contract('PublicKeys', async (accounts) => {
    const [seeker1, seeker2] = accounts;

    let instance;

    before(async () => {
        instance = await PublicKeys.new();
    });

    it('Attempt adding seeker1 public key for seeker2 (should fail)', async () => {
        const pub1 = `0x${pk[seeker1].public}`;
        try {
            await instance.addPublicKey(pub1, { from: seeker2 });
            assert.fail('Shouldn\'t get here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('Adding seeker public keys', async () => {
        const pub1 = `0x${pk[seeker1].public}`;
        await instance.addPublicKey(pub1, { from: seeker1 });
        await instance.addPublicKey(`0x${pk[seeker2].public}`, { from: seeker2 });

        // Retrieve stored pub key
        const pub1Test = await instance.publicKeyStore(seeker1);

        assert(pub1, pub1Test);
    });
});
