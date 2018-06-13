// Define these truffle-injected globals so that eslint doesn't complain.
const { artifacts, contract, assert } = global;

const { getLogArgument } = require('./util/logs.js');
const { sha256 } = require('js-sha256');

const Certificates = artifacts.require('Certificates');
const Issuers = artifacts.require('Issuers');

const sampleCertificateAWS = {
    title: 'AWS Certified Developer - John Smith - 02/02/2018',
    issuer: 'Amazon',
    student: 'John Smith',
    expires: 1580533200000, // 1/1/2020
};

const sampleCertificateMS = {
    title: 'Microsoft Certified IT Professional - John Smith',
    issuer: 'Microsoft',
    student: 'John Smith',
    expires: 1580533200000,
};

contract('Certificates', (accounts) => {
    let ownerAddress,
        user1address,
        user2address,
        issuer1address,
        issuer1name,
        issuer2address,
        issuer2name,
        unregisteredIssuer;


    let instance;
    let issuers;

    before(async () => {
        [
            ownerAddress,
            user1address,
            user2address,
            issuer1address,
            issuer2address,
            unregisteredIssuer,
        ] = accounts;

        issuer1name = 'Amazon';
        issuer2name = 'Microsoft';

        issuers = await Issuers.new();
        instance = await Certificates.new(issuers.address);

        // Setting Issuers contract address
        await instance.setIssuersContract(issuers.address, { from: ownerAddress });

        // Add issuers to issuers contract
        await issuers.addIssuer(issuer1address, issuer1name, { from: ownerAddress });
        await issuers.addIssuer(issuer2address, issuer2name, { from: ownerAddress });
    });

    it('Check issuers contract', async () => {
        const issuersAddress = await instance.issuersContract();
        assert.equal(issuersAddress, issuers.address, 'Issuers address should match');
    });

    it('Add a user certificate', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;
        const certificateId = `0x${sha256(sampleCertificateAWS.title)}`;
        const { expires } = sampleCertificateAWS;

        const tx = await instance.addCertificate(
            user1address,
            certificateHash,
            certificateId,
            expires,
            { from: issuer1address }
        );

        const addr = getLogArgument(tx.logs, 'LogAddCertificate', '_userAddress');
        const id = getLogArgument(tx.logs, 'LogAddCertificate', '_certificateId');

        // Check event
        assert.equal(addr, user1address, 'User Certificate was Added.');
        assert.equal(id, certificateId, 'User Certificate id should match.');

        // Check that user is stored
        const isUser = await instance.isUser(user1address);
        assert.equal(isUser, true, 'User should exists at their address');
    });

    it('Add second user certificate for the same user', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateMS))}`;
        const certificateId = `0x${sha256(sampleCertificateMS.title)}`;
        const { expires } = sampleCertificateMS;

        const tx = await instance.addCertificate(
            user1address,
            certificateHash,
            certificateId,
            expires,
            { from: issuer2address }
        );

        const addr = getLogArgument(tx.logs, 'LogAddCertificate', '_userAddress');
        const id = getLogArgument(tx.logs, 'LogAddCertificate', '_certificateId');

        // Check event
        assert.equal(addr, user1address, 'User address shoudl match');
        assert.equal(id, certificateId, 'User Certificate id should match');
    });

    it('Attempt to add a user certificate by unregistered Issuer', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;
        const certificateId = `0x${sha256(sampleCertificateAWS.title)}`;
        const { expires } = sampleCertificateAWS;

        let error;
        try {
            await instance.addCertificate(
                user1address,
                certificateHash,
                certificateId,
                expires,
                { from: unregisteredIssuer }
            );
        } catch (e) {
            error = e;
        }

        assert.ok(error instanceof Error);
    });

    it('Retrieving user certificate', async () => {
        const certificateId = `0x${sha256(sampleCertificateAWS.title)}`;

        const testCertificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;
        const testExpires = sampleCertificateAWS.expires;

        const [certHash, issuer, expiresOn] =
            await instance.getCertificate(user1address, certificateId);

        assert.equal(certHash, testCertificateHash, 'Certificate hash should match');
        assert.equal(issuer, issuer1address, 'Issuer shoudl match');
        assert.equal(expiresOn.toNumber(), testExpires, 'Expiration date should match');
    });

    it('Attempt to retrieve a user certificate for a non-existing user', async () => {
        const certificateId = `0x${sha256('something')}`;

        let error;
        try {
            await instance.getCertificate(user2address, certificateId);
        } catch (e) {
            error = e;
        }
        assert.ok(error instanceof Error);
    });

    it('Get user certificate count', async () => {
        const cnt = await instance.getCertificateCount(user1address);
        assert.equal(cnt.toNumber(), 2, 'Certificate count should be 1');
    });

    it('Get user index', async () => {
        const index = await instance.getUserIndex(user1address);
        assert.equal(index, 0, 'User index should be 0');
    });

    it('Get user address at index', async () => {
        const addr = await instance.getUserAtIndex(0);
        assert.equal(addr, user1address, 'User address should match');
    });

    it('Get user count', async () => {
        const cnt = await instance.getUserCount();
        assert.equal(cnt, 1, 'User count should be 1');
    });

    it('Testing throwing require() in getUserIndex()', async () => {
        let error;
        try {
            // Should throw as user 2 has not been added
            await instance.getUserIndex(user2address);
        } catch (err) {
            error = err;
        }

        assert.ok(error instanceof Error);
    });

    it('Testing getting user at non-existing index', async () => {
        let error;
        try {
            await instance.getUserAtIndex(10);
        } catch (e) {
            error = e;
        }

        assert.ok(error instanceof Error);
    });

    it('Testing throwing require() in getUserCertificateCount()', async () => {
        let error;
        try {
            // Should throw as user 2 has not been added
            await instance.getCertificateCount(user2address);
        } catch (err) {
            error = err;
        }

        assert.ok(error instanceof Error);
    });

    it('Testing echo', async () => {
        const echoAddress = await instance.whoami();
        assert.equal(echoAddress.toLowerCase(), ownerAddress.toLowerCase(), 'Sender address should match');
    });
});

