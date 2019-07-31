const { artifacts, contract, assert } = global;
const Ownable = artifacts.require('Ownable');
const { getLogArguments } = require('./util/logs.js');

const zeroAddress = '0x0000000000000000000000000000000000000000';

contract('Ownable', (accounts) => {
    let ownerAddress,
        nonOwnerAddress;

    let instance;

    before(async () => {
        [
            ownerAddress,
            nonOwnerAddress,
        ] = accounts;

        instance = await Ownable.new();
    });

    it('Contract creator is the initial contract owner', async () => {
        const owner = await instance.owner();
        assert.equal(owner, ownerAddress);
    });

    it('Can not transfer ownership to a zero address', async () => {
        try {
            await instance.transferOwnership(zeroAddress);
            assert.fail('Shouldn\' be able to transfer ownership to zero address');
        } catch (error) {
            assert.equal(error.reason, 'Unable to change the Owner to 0x0 address');
        }
    });

    it('Can not transfer ownership by a non-owner', async () => {
        try {
            await instance.transferOwnership(nonOwnerAddress, { from: nonOwnerAddress });
            assert.fail('Non-owner shouldn\'t be allowed to change ownership');
        } catch (error) {
            assert.equal(error.reason, 'Message sender is not contract Owner');
        }
    });

    it('Owner can transfer ownership', async () => {
        const tx = await instance.transferOwnership(nonOwnerAddress);
        // Make sure the emitted event has expected values
        const args = getLogArguments(tx.logs, 'OwnershipTransferred');
        assert.equal(ownerAddress, args.previousOwner);
        assert.equal(nonOwnerAddress, args.newOwner);

        // Check the actual new owner
        const newOwner = await instance.owner();
        assert.equal(newOwner, nonOwnerAddress);
    });
});
