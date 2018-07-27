/* eslint no-console: off, no-control-regex: "off" */

// Define these truffle-injected globals so that eslint doesn't complain.
const { artifacts, contract, assert } = global;

const Issuers = artifacts.require('Issuers');

// Should match IssuerStatus enum in Issuers contract
const IssuerStatus = { None: 0, Active: 1, Inactive: 2 };

contract('Issuers', (accounts) => {
    let ownerAddress,
        issuer1address;

    let instance;

    before(async () => {
        [
            ownerAddress,
            issuer1address,
        ] = accounts;

        instance = await Issuers.new();
    });

    it('Removing a non-existing Issuer', async () => {
        await instance.removeIssuer(issuer1address, { from: ownerAddress });
        assert.ok((await instance.getIssuerStatus(issuer1address)).equals(IssuerStatus.None), 'Issuer staus should be 0 (non-existing)');
    });

    it('Adding an Issuer', async () => {
        await instance.addIssuer(issuer1address, { from: ownerAddress });
        assert.ok((await instance.getIssuerStatus(issuer1address)).equals(IssuerStatus.Active), 'Issuer staus should be 1 (active)');
    });

    it('Removing an existing Issuer', async () => {
        await instance.removeIssuer(issuer1address, { from: ownerAddress });
        assert.ok((await instance.getIssuerStatus(issuer1address)).equals(IssuerStatus.Inactive), 'Issuer staus should be 2 (inactive)');
    });

    it('Re-adding an existing inactive Issuer', async () => {
        // First, make sure the user is inactive
        assert.ok((await instance.getIssuerStatus(issuer1address)).equals(IssuerStatus.Inactive), 'Issuer staus should be 2 (inactive)');
        await instance.addIssuer(issuer1address, { from: ownerAddress });
        assert.ok((await instance.getIssuerStatus(issuer1address)).equals(IssuerStatus.Active), 'Issuer staus should be 1 (active)');
    });
});
