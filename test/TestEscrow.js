/* eslint no-return-assign: off */
const {
    artifacts,
    contract,
    assert,
} = global;

const Escrow = artifacts.require('Escrow');
const PathToken = artifacts.require('PathToken');
const Certificates = artifacts.require('Certificates');
const Issuers = artifacts.require('Issuers');
const PublicKeys = artifacts.require('PublicKeys');

const { sha256 } = require('js-sha256');
//const EthCrypto = require('eth-crypto');

// Public/private keys for mnemonic:
// 'kiwi just service vital feature rural vibrant copy pledge useless fee forum'
const pk = require('./pk.json');

//const keys = require('./util/keys');
const cert = require('./samples/certifcicates/cert');

//const { publicKey, address } = keys.generateKeys(1);

contract('Escrow', async (accounts) => {
    const [
        owner,
        user1,
        user2,
        seeker1, // Registered
        seeker2, // Unregistered
        issuer1,
        issuer2,
    ] = accounts;

    const cert1 = cert(issuer1, user1, 'Ethereum professional');
    const cert2 = cert(issuer2, user2, 'Bitcoin enthusiast');
    const cert3 = cert(issuer2, user2, 'Blockchain professional - FAKE!');

    const cert1sha = `0x${sha256(JSON.stringify(cert1))}`;
    const cert2sha = `0x${sha256(JSON.stringify(cert2))}`;
    const cert3sha = `0x${sha256(JSON.stringify(cert3))}`;

    let token,
        certificates,
        issuers,
        publicKeys,
        escrow;

    before(async () => {
        token = await PathToken.new();
        issuers = await Issuers.new();
        certificates = await Certificates.new(issuers.address);
        publicKeys = await PublicKeys.new();
        escrow = await Escrow.new(token.address, certificates.address, publicKeys.address);

        // ########## Add initial data ###############
        // Whitelist the issuers
        await issuers.addIssuer(issuer1);
        await issuers.addIssuer(issuer2);
        // Add test certificates
        await certificates.addCertificate(user1, cert1sha, { from: issuer1 });
        await certificates.addCertificate(user2, cert2sha, { from: issuer2 });
        await certificates.addCertificate(user2, cert3sha, { from: issuer2 });
        // Revoke this cert
        await certificates.revokeCertificate(user2, 1, { from: issuer2 });

        // Add seeker1'a public keys (register the seeker)
        await publicKeys.addPublicKey(`0x${pk[seeker1].public}`, { from: seeker1 });
        // Give seeker1 1000 PATH tokens (1000 * 10**6)
        await token.transfer(seeker1, 1000 * 1000000, { from: owner });
    });

    it('Attempt to refund available balance for seeker1', async () => {
        const balanceSeeker1 = await token.balanceOf(seeker1);
        const balanceEscrow = await token.balanceOf(escrow.address);

        await token.approve(escrow.address, 42 * 1000000, { from: seeker1 });
        await escrow.increaseAvailableBalance(42 * 1000000, { from: seeker1 });

        const balanceSeeker1New = await token.balanceOf(seeker1);
        const balanceEscrowNew = await token.balanceOf(escrow.address);

        assert.equal(balanceSeeker1New.toNumber(), balanceSeeker1.toNumber() - (42 * 1000000));
        assert.equal(balanceEscrowNew.toNumber(), balanceEscrow.toNumber() + (42 * 1000000));

        await escrow.refundAvailableBalance({ from: seeker1 });

        const balanceSeeker1Refund = await token.balanceOf(seeker1);
        const balanceEscrowRefund = await token.balanceOf(escrow.address);

        assert.equal(balanceSeeker1Refund.toNumber(), balanceSeeker1.toNumber());
        assert.equal(balanceEscrowRefund.toNumber(), balanceEscrow.toNumber());
    });

    it('Attempt to place a request by unregistered seeker2', async () => {
        try {
            await escrow.submitRequest(user1, cert1sha, { from: seeker2 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('Attempt placing a request by registered seeker1 without allowing funds transfer', async () => {
        try {
            await escrow.submitRequest(user1, cert1sha, { from: seeker1 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
        // Retrieve the request
        //const dr = await escrow.getDataRequestByHash(user1, cert1sha);

        //console.log(dr);
    });

    it('Attempt placing a request for revoked certificate by registered seeker1', async () => {
        try {
            await token.approve(escrow.address, 25 * 1000000, { from: seeker1 });
            await escrow.submitRequest(user2, cert3sha, { from: seeker1 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('Place a request by registered seeker1 with allowing funds transfer', async () => {
        await token.approve(escrow.address, 25 * 1000000, { from: seeker1 });
        await escrow.submitRequest(user1, cert1sha, { from: seeker1 });

        // Retrieve the request
        const [seeker, status, hash, timestamp] =
            await escrow.getDataRequestByHash(user1, cert1sha);

        assert.equal(seeker, seeker1, 'Seeker should match');
        assert.equal(status, 1, 'Status should be 1 (Initial)');
        assert.equal(hash, cert1sha, 'Hash should match');

        const ts = timestamp.toNumber();
        const now = new Date().getTime() / 1000;

        assert.ok(ts > now - 10, 'Hash should match');
    });

    it('Place a request by registered seeker1 which has available balance in escrow contract', async () => {
        await token.approve(escrow.address, 25 * 1000000, { from: seeker1 });
        await escrow.increaseAvailableBalance(25 * 1000000, { from: seeker1 });
        await escrow.submitRequest(user1, cert1sha, { from: seeker1 });

        // Retrieve the request
        const [seeker, status, hash, timestamp] =
            await escrow.getDataRequestByHash(user1, cert1sha);

        assert.equal(seeker, seeker1, 'Seeker should match');
        assert.equal(status, 1, 'Status should be 1 (Initial)');
        assert.equal(hash, cert1sha, 'Hash should match');

        const ts = timestamp.toNumber();
        const now = new Date().getTime() / 1000;

        assert.ok(ts > now - 10, 'Hash should match');
    });

    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
    // it('', async () => {});
});
