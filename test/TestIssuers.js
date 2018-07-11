/* eslint no-console: off, no-control-regex: "off" */

// Define these truffle-injected globals so that eslint doesn't complain.
const { artifacts, contract, assert } = global;

const { getLogArgument } = require('./util/logs.js');

const Issuers = artifacts.require('Issuers');

contract('Issuers', (accounts) => {
    let ownerAddress,
        tempOwnerAddress,
        deputyAddress,
        issuer1address;

    let instance;

    before(async () => {
        [
            ownerAddress,
            tempOwnerAddress,
            deputyAddress,
            issuer1address,
        ] = accounts;

        instance = await Issuers.new();
    });

    // Test Deputable interface
    it('Changing owner using Ownerable interface', async () => {
        const tx = await instance.transferOwnership(tempOwnerAddress, { from: ownerAddress });
        const newOwnerFromLog = getLogArgument(tx.logs, 'OwnershipTransferred', 'newOwner');
        const newOwnerFromState = await instance.owner();

        assert.equal(newOwnerFromLog, tempOwnerAddress, 'New owner should match temp owner address');
        assert.equal(newOwnerFromState, tempOwnerAddress, 'New owner should match temp owner address');

        // Now change back to original owner
        await instance.transferOwnership(ownerAddress, { from: tempOwnerAddress });
        // Make sure the transfer was successful
        const ownerFromState = await instance.owner();

        assert.equal(ownerFromState, ownerAddress, 'Qwner should match the owner address');
    });

    it('Attempting to transfer the ownership to 0x0', async () => {
        let error;

        try {
            await instance.transferOwnership(0x0, { from: ownerAddress });
        } catch (e) {
            error = e;
        }

        assert.ok(error instanceof Error);
    });

    it('Attempt to transfer the owner by a non-owner', async () => {
        let error;

        try {
            await instance.transferOwnership(issuer1address, { from: issuer1address });
        } catch (e) {
            error = e;
        }

        assert.ok(error instanceof Error);
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
        const tx = await instance.setDeputy(0x0, { from: deputyAddress });
        const deputyFromLog = getLogArgument(tx.logs, 'DeputyModified', 'newDeputy');
        const deputyFromState = await instance.deputy();

        assert.equal(deputyFromLog, 0x0, 'Deputy should match');
        assert.equal(deputyFromState, 0x0, 'Deputy should match');
    });
    // ------------------------

    it('Removing a non-existing Issuer', async () => {
        await instance.removeIssuer(issuer1address, { from: ownerAddress });
        // Check Issuer status
        assert.equal((await instance.getIssuerStatus.call(issuer1address)).toNumber(), 0, 'Issuer staus should be 0 (non-existing)');
    });

    it('Adding an Issuer', async () => {
        // Add an issuer
        await instance.addIssuer(issuer1address, { from: ownerAddress });
        // Check Issuer status
        assert.equal((await instance.getIssuerStatus.call(issuer1address)).toNumber(), 1, 'Issuer staus should be 1 (active)');
    });

    it('Removing an existing Issuer', async () => {
        await instance.removeIssuer(issuer1address, { from: ownerAddress });
        // Check Issuer status
        assert.equal((await instance.getIssuerStatus.call(issuer1address)).toNumber(), 2, 'Issuer staus should be 2 (inactive)');
    });

    it('Re-adding an existing inactive Issuer', async () => {
        await instance.addIssuer(issuer1address, { from: ownerAddress });
        // Check Issuer status
        assert.equal((await instance.getIssuerStatus.call(issuer1address)).toNumber(), 1, 'Issuer staus should be 2 (active)');
    });
});
