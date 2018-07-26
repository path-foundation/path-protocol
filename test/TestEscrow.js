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

const decimals = 10 ** 6;
const requestPrice = 30 * decimals;

// Shoudl match RequestStatus enum in Escrow contract
const RequestStatus = {
    None: 0,
    Initial: 1,
    UserCompleted: 2,
    UserDenied: 3,
    SeekerCompleted: 4,
    SeekerFailed: 5,
    SeekerCancelled: 6,
};

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

    const cert1 = JSON.stringify(cert(issuer1, user1, 'Ethereum professional'));
    const cert2 = JSON.stringify(cert(issuer2, user2, 'Bitcoin enthusiast'));
    const cert3 = JSON.stringify(cert(issuer2, user2, 'Blockchain professional - FAKE!'));

    const cert1sha = `0x${sha256(cert1)}`;
    const cert2sha = `0x${sha256(cert2)}`;
    const cert3sha = `0x${sha256(cert3)}`;

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
        // User1 has two valid certs
        // User2 has a cert that wil get revoked
        await certificates.addCertificate(user1, cert1sha, { from: issuer1 });
        await certificates.addCertificate(user1, cert2sha, { from: issuer2 });
        await certificates.addCertificate(user2, cert3sha, { from: issuer2 });
        // Revoke this cert
        await certificates.revokeCertificate(user2, 0, { from: issuer2 });

        // Add seeker1'a public keys (register the seeker)
        await publicKeys.addPublicKey(`0x${pk[seeker1].public}`, { from: seeker1 });
        // Give seeker1 1000 PATH tokens (1000 * 10^6)
        await token.transfer(seeker1, 1000 * decimals, { from: owner });
    });

    it('Setting tokens per request', async () => {
        await escrow.setTokensPerRequest(requestPrice, { from: owner });

        assert.ok((await escrow.tokensPerRequest()).equals(requestPrice), 'Tokens per request should match the set amount');
    });

    it('Setting issuer reward', async () => {
        await escrow.setIssuerReward(60, { from: owner });

        assert.ok((await escrow.issuerReward()).equals(60), 'Issuer reward should match the set amount');
    });

    it('Attempt to increase available balance without setting allowance', async () => {
        try {
            // This call should fail because seeker1 didn't approve the transfer of 100 PATH
            // by escrow address prior to calling increaseAvailableBalance
            await escrow.increaseAvailableBalance(100 * decimals, { from: seeker1 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('Attempt to refund zero available balance', async () => {
        try {
            await escrow.refundAvailableBalance({ from: seeker1 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('Attempt to refund zero available balance by Admin', async () => {
        try {
            await escrow.refundAvailableBalanceAdmin(seeker1, { from: owner });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    // Test the refund available balance functionality
    it('Refund available balance', async () => {
        const balanceSeeker1 = await token.balanceOf(seeker1);
        const balanceEscrow = await token.balanceOf(escrow.address);

        // Seeker transfers 100 PATH to their available balance on the escrow
        await token.approve(escrow.address, 100 * decimals, { from: seeker1 });
        await escrow.increaseAvailableBalance(100 * decimals, { from: seeker1 });

        const balanceSeeker1New = await token.balanceOf(seeker1);
        const balanceEscrowNew = await token.balanceOf(escrow.address);

        assert.equal(balanceSeeker1New.toNumber(), balanceSeeker1.toNumber() - (100 * decimals));
        assert.equal(balanceEscrowNew.toNumber(), balanceEscrow.toNumber() + (100 * decimals));

        // Request a refund of available funds from the escrow contract
        await escrow.refundAvailableBalance({ from: seeker1 });

        const balanceSeeker1Refund = await token.balanceOf(seeker1);
        const balanceEscrowRefund = await token.balanceOf(escrow.address);

        assert.equal(balanceSeeker1Refund.toNumber(), balanceSeeker1.toNumber());
        assert.equal(balanceEscrowRefund.toNumber(), balanceEscrow.toNumber());
    });

    // Test the refund available balance functionality
    it('Refund available balance by an admin', async () => {
        const balanceSeeker1 = await token.balanceOf(seeker1);
        const balanceEscrow = await token.balanceOf(escrow.address);

        // Seeker transfers 100 PATH to their available balance on the escrow
        await token.approve(escrow.address, 100 * decimals, { from: seeker1 });
        await escrow.increaseAvailableBalance(100 * decimals, { from: seeker1 });

        const balanceSeeker1New = await token.balanceOf(seeker1);
        const balanceEscrowNew = await token.balanceOf(escrow.address);

        assert.equal(balanceSeeker1New.toNumber(), balanceSeeker1.toNumber() - (100 * decimals));
        assert.equal(balanceEscrowNew.toNumber(), balanceEscrow.toNumber() + (100 * decimals));

        // Request a refund of available funds from the escrow contract
        await escrow.refundAvailableBalanceAdmin(seeker1, { from: owner });

        const balanceSeeker1Refund = await token.balanceOf(seeker1);
        const balanceEscrowRefund = await token.balanceOf(escrow.address);

        assert.equal(balanceSeeker1Refund.toNumber(), balanceSeeker1.toNumber());
        assert.equal(balanceEscrowRefund.toNumber(), balanceEscrow.toNumber());
    });

    it('Attempt gettign a data request index by non-existing hash', async () => {
        const i = await escrow.getDataRequestIndexByHash(user1, `0x${sha256('blah')}`);
        assert.ok(i.equals(-1));
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
    });

    it('Attempt placing a request for revoked certificate by registered seeker1', async () => {
        try {
            await token.approve(escrow.address, requestPrice, { from: seeker1 });
            await escrow.submitRequest(user2, cert3sha, { from: seeker1 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('Place a request by registered seeker1 with allowing funds transfer', async () => {
        await token.approve(escrow.address, requestPrice, { from: seeker1 });
        await escrow.submitRequest(user1, cert1sha, { from: seeker1 });

        // Retrieve the request
        const [seeker, status, hash, timestamp] =
            await escrow.getDataRequestByHash(user1, cert1sha);

        assert.equal(seeker, seeker1, 'Seeker should match');
        assert.equal(status, RequestStatus.Initial, 'Status should be 1 (Initial)');
        assert.equal(hash, cert1sha, 'Hash should match');

        const ts = timestamp.toNumber();
        const now = new Date().getTime() / 1000;

        assert.ok(ts > now - 10, 'Hash should match');
    });

    it('Place a request by registered seeker1 that has available balance in the escrow contract', async () => {
        await token.approve(escrow.address, requestPrice, { from: seeker1 });
        // Increatse seeker1's available balance
        await escrow.increaseAvailableBalance(requestPrice, { from: seeker1 });
        await escrow.submitRequest(user1, cert2sha, { from: seeker1 });

        // Retrieve the request by hash
        const [seeker, status, hash, timestamp] =
            await escrow.getDataRequestByHash(user1, cert2sha);

        assert.equal(seeker, seeker1, 'Seeker should match');
        assert.equal(status, RequestStatus.Initial, 'Status should be 1 (Initial)');
        assert.equal(hash, cert2sha, 'Hash should match');

        const ts = timestamp.toNumber();
        const now = new Date().getTime() / 1000;

        assert.ok(ts > now - 10, 'Hash should match');

        // Retrieve the request by index
        const i = await escrow.getDataRequestIndexByHash(user1, cert2sha);
        const [seekerI, statusI, hashI, timestampI] = await escrow.getDataRequestByIndex(user1, i);

        assert.equal(seeker, seekerI, 'Seeker should match');
        assert.ok(status.equals(statusI), 'Status should match');
        assert.equal(hash, hashI, 'Hash should match');
        assert.ok(timestamp.equals(timestampI), 'Timestamp should match');
    });

    it('Check number of requests for a user', async () => {
        const user1count = await escrow.getDataRequestCount(user1);
        const user2count = await escrow.getDataRequestCount(user2);

        assert.ok(user1count.equals(2), 'User1 should have 2 requests');
        assert.ok(user2count.equals(0), 'User2 should have 0 requests');
    });

    it('User attempts to deny a request for nonexisting hash', async () => {
        try {
            await escrow.userDenyRequest(`0x${sha256('blah')}`, { from: user1 });
            assert.fail('Shouldn\'t be here');
        } catch (error) {
            assert.ok(true);
        }
    });

    it('User1 denies the request for cert1, initiated by seeker1', async () => {
        // Get seeker1 balance
        const prevBalance = await escrow.seekerAvailableBalance(seeker1);
        const prevInflightBalance = await escrow.seekerInflightBalance(seeker1);
        await escrow.userDenyRequest(cert1sha, { from: user1 });
        const newBalance = await escrow.seekerAvailableBalance(seeker1);
        const newInflightBalance = await escrow.seekerInflightBalance(seeker1);

        assert.ok(newBalance.equals(prevBalance + requestPrice), 'New avail balance should include the refund for denied request');
        assert.ok(newInflightBalance.equals(prevInflightBalance - requestPrice), 'New inflight balance should exclude the refund for denied request');
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
});
