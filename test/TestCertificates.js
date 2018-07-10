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

        const tx = await instance.addCertificate(
            user1address,
            certificateHash,
            { from: issuer1address }
        );

        const addr = getLogArgument(tx.logs, 'LogAddCertificate', '_userAddress');
        const hash = getLogArgument(tx.logs, 'LogAddCertificate', '_certificateHash');

        // Check event
        assert.equal(addr, user1address, 'User Certificate was Added.');
        assert.equal(hash, certificateHash, 'User Certificate id should match.');
    });

    it('Add second user certificate for the same user', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateMS))}`;

        const tx = await instance.addCertificate(
            user1address,
            certificateHash,
            { from: issuer2address }
        );

        const addr = getLogArgument(tx.logs, 'LogAddCertificate', '_userAddress');
        const hash = getLogArgument(tx.logs, 'LogAddCertificate', '_certificateHash');

        // Check event
        assert.equal(addr, user1address, 'User address should match');
        assert.equal(hash, certificateHash, 'User Certificate hash should match');
    });

    it('Attempt to add a user certificate by unregistered Issuer', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;
        const { expires } = sampleCertificateAWS;

        let error;
        try {
            await instance.addCertificate(
                user1address,
                certificateHash,
                expires,
                { from: unregisteredIssuer }
            );
        } catch (e) {
            error = e;
        }

        assert.ok(error instanceof Error);
    });

    it('Retrieving user certificate', async () => {
        const testCertificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;

        const [issuer, revoked] =
            await instance.getCertificateMetadata(user1address, testCertificateHash);

        assert.equal(revoked, false, 'Certificate should not be revoked');
        assert.equal(issuer, issuer1address, 'Issuer should match');
    });

    it('Attempt to retrieve a user certificate for a non-existing user', async () => {
        const certificateHash = `0x${sha256('something')}`;

        const [issuer] =
            await instance.getCertificateMetadata(user2address, certificateHash);

        assert.ok(issuer, 0x0);
    });

    it('Get user certificate count', async () => {
        const cnt = await instance.getCertificateCount(user1address);
        assert.equal(cnt.toNumber(), 2, 'Certificate count should be 1');
    });

    it('Get user certificate at index that exists', async () => {
        const [certificateHash, issuer, revoked] = await instance.getCertificateAt(user1address, 0);

        const testHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;

        assert.equal(certificateHash, testHash, 'Certificate hash doesn\'t match');
        assert.equal(issuer, issuer1address, 'Issuer should be issuer1');
        assert.equal(revoked, false, 'Certificate shouldn\t be revoked');
    });

    it('Revoke user1 certificate', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;

        const i = await instance.getCertificateIndex(user1address, certificateHash);
        const tx = await instance.revokeCertificate(user1address, i, { from: issuer1address });

        const result =
            await instance.getCertificateMetadata(user1address, certificateHash);

        const revoked = result[1];

        assert.equal(revoked, true, 'Certificate should be revoked');

        const testAddress = getLogArgument(tx.logs, 'LogCertificateRevoked', '_userAddress');

        assert.equal(user1address, testAddress, 'Event should contain user1 address');
    });

    it('Revoke user1 certificate by another issuer', async () => {
        const certificateHash = `0x${sha256(JSON.stringify(sampleCertificateAWS))}`;

        const i = await instance.getCertificateIndex(user1address, certificateHash);

        try {
            await instance.revokeCertificate(user1address, i, { from: issuer2address });
            assert.equal(1, 2, 'Should not get here');
        } catch (error) {
            assert.ok(error instanceof Error);
        }
    });

    it('Testing echo', async () => {
        const echoAddress = await instance.whoami();
        assert.equal(echoAddress.toLowerCase(), ownerAddress.toLowerCase(), 'Sender address should match');
    });
});

