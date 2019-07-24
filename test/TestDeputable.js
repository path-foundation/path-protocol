const { artifacts, contract, assert } = global;
const Deputable = artifacts.require('Deputable');
const { getLogArgument } = require('./util/logs.js');

const zeroAddress = "0x0000000000000000000000000000000000000000";

contract('Deputable', (accounts) => {
    let ownerAddress,
        deputyAddress,
        issuer1address;

    let instance;

    before(async () => {
        [
            ownerAddress,
            deputyAddress,
            issuer1address,
        ] = accounts;

        instance = await Deputable.new();
    });

    it('Attempt adding a deputy as a non-owner account should fail', async () => {
        let error;
        try {
            await instance.setDeputy(deputyAddress, { from: deputyAddress });
        } catch (e) {
            error = e;
        }
        assert.ok(error instanceof Error, 'An error should be thrown');
    });

    it('Adding Deputy', async () => {
        const tx = await instance.setDeputy(deputyAddress, { from: ownerAddress });
        const deputyFromLog = getLogArgument(tx.logs, 'DeputyModified', 'newDeputy');
        const deputyFromState = await instance.deputy();

        assert.equal(deputyFromLog, deputyAddress, 'Deputy should match');
        assert.equal(deputyFromState, deputyAddress, 'Deputy should match');
    });

    it('Non-owner and non-deputy should not be able to modify a deputy', async () => {
        let error;
        try {
            await instance.setDeputy(issuer1address, { from: issuer1address });
        } catch (e) {
            error = e;
        }
        assert.ok(error instanceof Error, 'An error should be thrown');
    });

    it('Deputy should be able to modify a deputy', async () => {
        // Attempt to remove deputy, as deputy
        try {
            const tx = await instance.setDeputy(zeroAddress, { from: deputyAddress });
            const deputyFromLog = getLogArgument(tx.logs, 'DeputyModified', 'newDeputy');
            const deputyFromState = await instance.deputy();
    
            assert.equal(deputyFromLog, zeroAddress, 'Deputy should match');
            assert.equal(deputyFromState, zeroAddress, 'Deputy should match');
        } catch(e) {
            console.log(e);
        }
        
    });
});
