// Define these truffle-injected globals
// so that eslint doesn't complain.
const { artifacts, contract, assert } = global;

const PathToken = artifacts.require('PathToken');

contract('PathToken', (accounts) => {
    let ownerAddress,
        tempOwnerAddress,
        user1Address,
        user2Address;

    let instance;

    before(async () => {
        [ownerAddress, tempOwnerAddress, user1Address, user2Address] = accounts;
        // ownerAddress = accounts[0];
        // tempOwnerAddress = accounts[1];
        // user1Address = accounts[2];
        // user2Address = accounts[3];

        instance = await PathToken.deployed();

        const owner = await instance.owner();
        console.log(`Owner: ${owner}`);
    });

    it('Test rejecting ETH payment into the token contract', async () => {
        await instance.sendTransaction({ from: accounts[0], value: 1 })
            .then(() => {
                // if we get here, the transaction wasn't rejected, which is an unexpected behavior
                assert.fail();
            })
            .catch(() => {
                // TODO: make sure we get the expected error
                assert.ok(true);
            });
    });

    describe('Test the Ownable interface', () => {
        it('Test retrieving current owner', async () => {
            const owner = await instance.owner();
            assert.equal(owner, ownerAddress, 'Owner address shouls match the first account address');
        });

        it('Test changing ownership', async () => {
            // Transfer the ownership
            await instance.transferOwnership(tempOwnerAddress).then((tx) => {
                // Check for OwnershipTransferred event
                assert.equal(1, tx.logs.length, 'There should be one OwnershipTransferred event');
                assert.equal(ownerAddress, tx.logs[0].args.previousOwner);
                assert.equal(tempOwnerAddress, tx.logs[0].args.newOwner);
            });

            const owner = await instance.owner();
            assert.equal(owner, tempOwnerAddress, 'Owner address should match the second account address');
        });

        it('Test chaning ownership back to the original owner', async () => {
            await instance.transferOwnership(ownerAddress, { from: tempOwnerAddress });
            const owner = await instance.owner();
            assert.equal(owner, ownerAddress, 'Owner address shouls match the second account address');
        });

        it('Test transferring ownership by a non-owner account', async () => {
            // Try to change owner using a non-owner account - should err
            await instance.transferOwnership(ownerAddress, { from: tempOwnerAddress })
                .then(() => {
                    assert.fail();
                })
                .catch(() => {
                    assert.ok(true);
                });
        });

        it('Test transferring ownership to 0x0 account', async () => {
        // Try to transfer the ownership to 0x0 address
            await instance.transferOwnership('0x0')
                .then(() => {
                    assert.fail();
                })
                .catch(() => {
                    assert.ok(true);
                });
        });
    });

    describe('Test the deputable interface', () => {
        it('Assign a deputy', async () => {
            await instance.setDeputy(tempOwnerAddress, { from: ownerAddress });
            const deputy = await instance.deputy();
            assert.equal(deputy, tempOwnerAddress);
        });
    });

    it('Test initial supply', async () => {
        const totalSupply = await instance.totalSupply();

        assert.ok(totalSupply.equals('500000000000000'), 'Total supply should be 500,000,000,000,000');
    });

    it("Test initial owner's balance", async () => {
        const ownersBalance = await instance.balanceOf(ownerAddress);

        assert.ok(ownersBalance.equals('500000000000000'), 'Initial balance of the owner should be 500,000,000,000,000');
    });

    it('Test transferring to 0x0 address', async () => {
        await instance.transfer('0x0', 1)
            .then(() => {
                // if we get here, the transaction wasn't rejected, which is an unexpected behavior
                assert.fail();
            })
            .catch(() => {
                assert.ok(true);
            });
    });

    it('Test transferring some tokens from Owner to User1', async () => {
        await instance.transfer(user1Address, 100);
        const user1Balance = await instance.balanceOf(user1Address);

        assert.ok(user1Balance.equals(100), 'User 1 balance is wrong');
    });

    it('Should return the correct allowance amount after approval', async () => {
        // Approve owner to transfer 100 tokens from user1
        await instance.approve(ownerAddress, 100, { from: user1Address });
        const allowance = await instance.allowance(user1Address, ownerAddress);
        assert.ok(allowance.equals(100));
    });

    it('Owner transfers 40 tokens from user1 to user2', async () => {
        await instance.transferFrom(user1Address, user2Address, 40);

        const user1balance = await instance.balanceOf(user1Address);
        const user2balance = await instance.balanceOf(user2Address);

        assert.ok(user1balance.equals(60), 'User1 balance should be 60');
        assert.ok(user2balance.equals(40), 'User2 balance should be 40');
    });

    it('Test increasing allowance', async () => {
        // First, transfer 1000 tokens from owner to user1
        await instance.transfer(user1Address, 1000, { from: ownerAddress });
        // Allow owner to spend 420 tokens from user1 balance
        await instance.approve(ownerAddress, 420, { from: user1Address });
        // Now increase that approval by 47 tokens
        await instance.contract.increaseApproval.sendTransaction(
            ownerAddress,
            47,
            { from: user1Address }
        );
        // Check owner's allowance for spending user1's tokens - should be 467
        const allowance = await instance.allowance(user1Address, ownerAddress);

        assert.ok(allowance.equals(467));
    });
});
