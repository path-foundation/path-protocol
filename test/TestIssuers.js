/* eslint no-console: off */

// Define these truffle-injected globals so that eslint doesn't complain.
const artifacts = global.artifacts;
const contract = global.contract;
const assert = global.assert;

const getLogArgument = require('./util/logs.js').getLogArgument;
const web3 = require('web3');

const Issuers = artifacts.require('Issuers');

contract('Issuers', (accounts) => {
    let ownerAddress,
        tempOwnerAddress,
        deputyAddress,
        issuer1address,
        issuer1name,
        issuer2address;

    let instance;

    before(async () => {
        ownerAddress = accounts[0];
        tempOwnerAddress = accounts[1];
        deputyAddress = accounts[2];
        issuer1address = accounts[3];
        issuer1name = 'MIT';
        issuer2address = accounts[4];

        instance = await Issuers.deployed();
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

    it('Attempting to remove a non-existing Issuer', async () => {
        const tx = await instance.removeIssuer(issuer1address, { from: ownerAddress });
        const status = getLogArgument(tx.logs, 'LogRemoveIssuer', '_status');
        assert.equal(status, 1, 'Status should be 1 (NotFound)');
    });

    it('Adding an Issuer', async () => {
        // Add a uni
        const tx = await instance.addIssuer(issuer1address, issuer1name, { from: ownerAddress });
        assert.equal(getLogArgument(tx.logs, 'LogAddIssuer', '_status'), 0, 'Status should be 0 (Success)');

        // Check total Issuers
        assert.equal((await instance.getTotalIssuersCount()).toNumber(), 1, 'Total Issuers count should be 1');
        // Check active Issuers
        assert.equal((await instance.countActiveIssuers.call()).toNumber(), 1, 'Active Issuers count should be 1');
        // Check Issuer status
        assert.equal((await instance.getIssuerStatus.call(issuer1address)).toNumber(), 1, 'Issuer staus should be 1 (active)');
    });

    it('Removing an existing Issuer', async () => {
        const tx = await instance.removeIssuer(issuer1address, { from: ownerAddress });

        // check the log event
        assert.equal(getLogArgument(tx.logs, 'LogRemoveIssuer', '_status'), 0, 'Status should be 0 (Success)');

         // Check total Issuers
        assert.equal((await instance.getTotalIssuersCount()).toNumber(), 1, 'Total Issuers count should be 1');
         // Check active Issuers
        assert.equal((await instance.countActiveIssuers.call()).toNumber(), 0, 'Active Issuers count should be 0');
         // Check Issuer status
        assert.equal((await instance.getIssuerStatus.call(issuer1address)).toNumber(), 2, 'Issuer staus should be 2 (inactive)');
    });

    it('Attempting to remove an already removed/inactive Issuer', async () => {
        const tx = await instance.removeIssuer(issuer1address, { from: ownerAddress });

        // check the log event
        assert.equal(getLogArgument(tx.logs, 'LogRemoveIssuer', '_status'), 2, 'Status should be 2 (AlreadyInactive)');
    });

    it('Attempting to remove a non-existing Issuer', async () => {
        const tx = await instance.removeIssuer(issuer2address, { from: ownerAddress });

        // check the log event
        assert.equal(getLogArgument(tx.logs, 'LogRemoveIssuer', '_status'), 1, 'Status should be 1 (NotFound)');
    });

    it('Attempting to re-add an existing inactive Issuer', async () => {
        const tx = await instance.addIssuer(issuer1address, issuer1name, { from: ownerAddress });

        // check the log event
        assert.equal(getLogArgument(tx.logs, 'LogAddIssuer', '_status'), 0, 'Status should be 0 (Success)');
    });

    it('Attempting to re-add an existing active Issuer', async () => {
        const tx = await instance.addIssuer(issuer1address, issuer1name, { from: ownerAddress });

        // check the log event
        assert.equal(getLogArgument(tx.logs, 'LogAddIssuer', '_status'), 1, 'Status should be 1 (AlreadyExists)');
    });

    it('Retrieving issuer with specified index', async () => {
        const issuer = await instance.getIssuerAtIndex(0);
        const address = issuer[0]; // 0xf17f52151ebef6c7334fad080c5704d77216b732
        const name = web3.prototype.toAscii(issuer[1]).replace(/\u0000/g, ''); // MIT
        const status = issuer[2] * 1; // 1
        assert.equal(address, issuer1address, 'Should be uni1 address');
        assert.equal(name, issuer1name, 'Should be uni1 name');
        assert.equal(status, 1, 'Status should be 1');
    });

    it('Testing echo', async () => {
        const echoAddress = await instance.whoami();
        assert.equal(echoAddress.toLowerCase(), ownerAddress.toLowerCase(), 'Sender address should match');
    });
});
