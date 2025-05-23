const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("SUDO42 contract", function () {

    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();
        const hardhatToken = await ethers.deployContract("SUDO42");
        await hardhatToken.waitForDeployment();
        return { hardhatToken, owner, addr1, addr2 };
    }

    describe("Construction", function () {

        it("Should have 'SUDO42' as name", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.name()).to.equal("SUDO42");
        });

        it("Should have 'SUDO' as symbol", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.symbol()).to.equal("SUDO");
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
            await expect(hardhatToken.transfer(addr1.address, amount))
                .to.emit(hardhatToken, "Transfer")
                .withArgs(owner.address, addr1.address, amount);
        });

        it("Should fail if the sender does not have enough tokens", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(1_000_000) * BigInt(10) ** BigInt(18) + BigInt(1);
            await expect(hardhatToken.transfer(addr1.address, amount)).to.be.revertedWith(
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
            await expect(hardhatToken.transfer(addr1.address, amount))
                .to.emit(hardhatToken, "Transfer")
                .withArgs(owner.address, addr1.address, amount);
        });

    });

    describe("allowance", function () {

        it("Should return the allowance of the owner", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await hardhatToken.approve(addr1.address, amount);
            const allowance = await hardhatToken.allowance(owner.address, addr1.address);
            expect(allowance).to.equal(amount);
        });

        it("Should return 0 for an address with no allowance", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await hardhatToken.approve(addr1.address, amount);
            const allowance = await hardhatToken.allowance(owner.address, addr2.address);
            expect(allowance).to.equal(0);
        });

        it("Should allow setting allowance", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(500);
            await expect(hardhatToken.approve(addr1.address, amount))
                .to.emit(hardhatToken, "Approval")
                .withArgs(owner.address, addr1.address, amount);
            expect(await hardhatToken.allowance(owner.address, addr1.address)).to.equal(amount);
        });

        it("Should emit an Approval event", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await expect(hardhatToken.approve(addr1.address, amount))
                .to.emit(hardhatToken, "Approval")
                .withArgs(owner.address, addr1.address, amount);
        });

        it("Should fail if the spender is the zero address", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await expect(hardhatToken.approve("0x0000000000000000000000000000000000000000", amount)).to.be.revertedWith(
                "ERC20: approve to the zero address"
            );
        });

        it("Should allow spending within the approved allowance", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(200);
            await hardhatToken.approve(addr1.address, amount);

            await hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, amount);

            expect(await hardhatToken.balanceOf(addr2.address)).to.equal(amount);
            expect(await hardhatToken.allowance(owner.address, addr1.address)).to.equal(0);
        });

        it("Should fail if spender tries to spend more than allowed", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            const amount = BigInt(100);
            await hardhatToken.approve(addr1.address, amount);

            await expect(
                hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, amount + BigInt(1))
            ).to.be.revertedWith("ERC20: insufficient allowance");
        });

    });

    describe("Increase and Decrease Allowance", function () {

        it("Should increase the allowance", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const initialAmount = BigInt(200);
            await hardhatToken.approve(addr1.address, initialAmount);

            const increaseAmount = BigInt(100);
            await hardhatToken.increaseAllowance(addr1.address, increaseAmount);

            expect(await hardhatToken.allowance(owner.address, addr1.address)).to.equal(initialAmount + increaseAmount);
        });

        it("Should emit an Approval event on increaseAllowance", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const increaseAmount = BigInt(50);
            await expect(hardhatToken.increaseAllowance(addr1.address, increaseAmount))
                .to.emit(hardhatToken, "Approval")
                .withArgs(owner.address, addr1.address, increaseAmount);
        });

        it("Should decrease the allowance", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const initialAmount = BigInt(300);
            await hardhatToken.approve(addr1.address, initialAmount);

            const decreaseAmount = BigInt(100);
            await hardhatToken.decreaseAllowance(addr1.address, decreaseAmount);

            expect(await hardhatToken.allowance(owner.address, addr1.address)).to.equal(initialAmount - decreaseAmount);
        });

        it("Should fail if trying to decrease allowance below zero", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const initialAmount = BigInt(100);
            await hardhatToken.approve(addr1.address, initialAmount);

            await expect(
                hardhatToken.decreaseAllowance(addr1.address, initialAmount + BigInt(1))
            ).to.be.revertedWith("ERC20: decreased allowance below zero");
        });

    });

    describe("transferFrom", function () {

        it("Should allow transferFrom when approved", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            await hardhatToken.approve(addr1.address, 200);
            await hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 100);
            expect(await hardhatToken.balanceOf(addr2.address)).to.equal(100);
        });

        it("Should decrease allowance on transferFrom", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            await hardhatToken.approve(addr1.address, 200);
            await hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 100);
            expect(await hardhatToken.allowance(owner.address, addr1.address)).to.equal(100);
        });

        it("Should not allow transferFrom more than allowed", async function () {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            await hardhatToken.approve(addr1.address, 100);
            await expect(hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 200))
                .to.be.revertedWith("ERC20: insufficient allowance");
        });
    });

    describe("Edge Cases", function () {
        it("Should allow transferring to self", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            await hardhatToken.transfer(owner.address, 100);
            expect(await hardhatToken.balanceOf(owner.address)).to.be.gt(0);
        });

        it("Should not allow exceeding MaxUint96 in increaseAllowance", async function () {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            const MaxUint96 = BigInt(2) ** BigInt(96) - BigInt(1);
            await hardhatToken.approve(addr1.address, MaxUint96);
            await expect(hardhatToken.increaseAllowance(addr1.address, 1))
                .to.be.reverted;
        });

    });


});