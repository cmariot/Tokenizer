const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { MaxUint256 } = require("ethers");

describe("AlphaCoin42 contract", function () {

    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();
        const hardhatToken = await ethers.deployContract("AlphaCoin42");
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

    });


    describe("balanceOf", function () {

        it("Should return the balance of the owner", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            const totalSupply = await hardhatToken.totalSupply();
            expect(ownerBalance).to.equal(totalSupply);
        });

        it("Should return 0 for an address with no balance", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            expect(addr1.address).to.not.equal(owner.address);
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            const totalSupply = await hardhatToken.totalSupply();
            expect(ownerBalance).to.equal(totalSupply);
            const addr1Balance = await hardhatToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(0);
        });

    });


    describe("transfer", function () {

        it("Should transfer tokens between accounts", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await hardhatToken.transfer(addr1.address, amount);
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            const addr1Balance = await hardhatToken.balanceOf(addr1.address);
            const totalSupply = await hardhatToken.totalSupply();
            expect(ownerBalance).to.equal(totalSupply - amount);
            expect(addr1Balance).to.equal(amount);
        });

        it("Should emit a Transfer event", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await hardhatToken.transfer(addr1.address, amount);
            const transferEvents = await hardhatToken.queryFilter("Transfer");
            expect(transferEvents.length).to.equal(2);  // 1 for the deployment, 1 for the transfer
            const event = transferEvents[1];
            expect(event.args._from).to.equal(owner.address);
            expect(event.args._to).to.equal(addr1.address);
            expect(event.args._value).to.equal(amount);
        });

        it("Should fail if the sender does not have enough tokens", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(1_000_000) * BigInt(10) ** BigInt(18);
            hardhatToken.transfer(addr1.address, amount);
            await expect(hardhatToken.transfer(addr1.address, 1)).to.be.revertedWith(
                "ERC20: transfer amount exceeds balance"
            );

        });

        it("Should fail if the recipient is the zero address", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await expect(hardhatToken.transfer("0x0000000000000000000000000000000000000000", amount)).to.be.revertedWith(
                "ERC20: transfer to the zero address"
            );
        });

        it("Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(0);
            await hardhatToken.transfer(addr1.address, amount);
            const transferEvents = await hardhatToken.queryFilter("Transfer");
            expect(transferEvents.length).to.equal(2);  // 1 for the deployment, 1 for the transfer
            const event = transferEvents[1];
            expect(event.args._from).to.equal(owner.address);
            expect(event.args._to).to.equal(addr1.address);
            expect(event.args._value).to.equal(amount);
        });

        it("Should not be possible to transfer more than the total supply", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const totalSupply = await hardhatToken.totalSupply();
            await expect(hardhatToken.transfer(addr1.address, totalSupply + BigInt(1))).to.be.revertedWith(
                "ERC20: transfer amount exceeds total supply"
            );
        });

    });

});
