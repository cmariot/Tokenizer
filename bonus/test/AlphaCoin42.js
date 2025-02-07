const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { MaxUint256 } = require("ethers");


describe("AlphaCoin42 contract", function () {

    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();
        const hardhatToken = await ethers.deployContract("AlphaCoin42", [[owner.address, addr1.address], 2]);
        await hardhatToken.waitForDeployment();
        return { hardhatToken, owner, addr1, addr2 };
    }

    describe("Construction", function () {

        it("Should have 'AlphaCoin42' as name", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.name()).to.equal("AlphaCoin42");
        });

        it("Should have 'AC42' as symbol", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.symbol()).to.equal("AC42");
        });

        it("Should have 18 decimals", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.decimals()).to.equal(18);
        });

        it("Should have a total supply of 1,000,000", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            const totalSupply = await hardhatToken.totalSupply();
            const decimals = await hardhatToken.decimals();
            const expectedTotalSupply = BigInt(1_000_000) * BigInt(10) ** BigInt(decimals);
            expect(totalSupply).to.equal(expectedTotalSupply);
        });

        it("Should assign the total supply to the owner", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            const totalSupply = await hardhatToken.totalSupply();
            expect(ownerBalance).to.equal(totalSupply);
        });

        it("Should emit a Transfer event with the total supply", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            const totalSupply = await hardhatToken.totalSupply();
            const transferEvents = await hardhatToken.queryFilter("Transfer");
            expect(transferEvents.length).to.equal(1);
            const event = transferEvents[0];
            expect(event.args._from).to.equal('0x0000000000000000000000000000000000000000');
            expect(event.args._to).to.equal(owner.address);
            expect(event.args._value).to.equal(totalSupply);
        });

        it("Should set the owner as admin", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.isAdmin(owner.address)).to.be.true;
            expect(await hardhatToken.isAdmin(addr1.address)).to.be.false;
        });

        it("Should set the owner and addr1 as signers", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.isSigner(owner.address)).to.be.true;
            expect(await hardhatToken.isSigner(addr1.address)).to.be.true;
            expect(await hardhatToken.isSigner(addr2.address)).to.be.false;
        });

    });


    describe("Transfer", function () {

        it("Should submit transfer", async function () {

            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            const initialBalanceOwner = await hardhatToken.balanceOf(owner.address);
            const initialBalanceAddr2 = await hardhatToken.balanceOf(addr2.address);

            await hardhatToken.submitTransfer(addr2.address, 100);
            const transferEvents = await hardhatToken.queryFilter("TransferSubmitted");
            expect(transferEvents.length).to.equal(1);
            const event = transferEvents[0];
            console.error(event);
            const transactionId = BigInt(event.args._transactions_id);

            console.log("Type of transactionId", typeof transactionId);

            console.log('transactionId', transactionId);

            const nextBalanceOwner = await hardhatToken.balanceOf(owner.address);
            const nextBalanceAddr2 = await hardhatToken.balanceOf(addr2.address);

            // The owner balance should be decreased by 100, the addr2 balance should not change yet
            expect(nextBalanceOwner).to.equal(BigInt(initialBalanceOwner) - BigInt(100));
            expect(nextBalanceAddr2).to.equal(initialBalanceAddr2);

            // owner and addr1 are signers
            expect(await hardhatToken.isSigner(owner.address)).to.be.true;
            expect(await hardhatToken.isSigner(addr1.address)).to.be.true;
            // addr2 is not a signer
            expect(await hardhatToken.isSigner(addr2.address)).to.be.false;

            // Sign the transaction with as the owner
            await hardhatToken.connect(owner).signTransfer(transactionId);
            console.error('owner signed');
            // Sign the transaction with as the addr1
            await hardhatToken.connect(addr1).signTransfer(transactionId);

            // The transaction should be executed
            const newBalanceAddr2 = await hardhatToken.balanceOf(addr2.address);
            console.error(newBalanceAddr2);

            // The addr2 balance should be increased by 100
            // expect(newBalanceAddr2).to.equal(BigInt(initialBalanceAddr2) + BigInt(100));
        });

    });

});