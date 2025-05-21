const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TavernGoldToken", function () {
    let TavernGoldToken;
    let token;
    let owner;
    let addr1;
    let addr2;
    let initialSupply;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        TavernGoldToken = await ethers.getContractFactory("TavernGoldToken");
        [owner, addr1, addr2] = await ethers.getSigners();
        initialSupply = ethers.parseEther("1000000"); // 1 million tokens

        // Deploy a new contract before each test
        token = await TavernGoldToken.deploy(initialSupply);
        await token.waitForDeployment();
    });

    describe("Basic Token Functionality", function () {
        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await token.balanceOf(owner.address);
            expect(await token.totalSupply()).to.equal(ownerBalance);
        });

        it("Should transfer tokens between accounts", async function () {
            await token.transfer(addr1.address, 50);
            const addr1Balance = await token.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(50);

            await token.connect(addr1).transfer(addr2.address, 50);
            const addr2Balance = await token.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

        it("Should fail if sender doesn't have enough tokens", async function () {
            const initialOwnerBalance = await token.balanceOf(owner.address);
            await expect(
                token.connect(addr1).transfer(owner.address, 1)
            ).to.be.reverted;
            expect(await token.balanceOf(owner.address)).to.equal(
                initialOwnerBalance
            );
        });
    });

    describe("Role Management", function () {
        it("Should assign the DEFAULT_ADMIN_ROLE to the owner", async function () {
            const hasRole = await token.hasRole(
                await token.DEFAULT_ADMIN_ROLE(),
                owner.address
            );
            expect(hasRole).to.be.true;
        });

        it("Should assign the TOKEN_MINTER_ROLE to the owner", async function () {
            const hasRole = await token.hasRole(
                await token.TOKEN_MINTER_ROLE(),
                owner.address
            );
            expect(hasRole).to.be.true;
        });
    });

    describe("Tipping", function () {
        it("Should allow users to send tips", async function () {
            const tipAmount = ethers.parseEther("100");
            const message = "Great session!";

            // Transfer some tokens to addr1 first
            await token.transfer(addr1.address, tipAmount);

            // Send tip from addr1 to addr2
            await expect(token.connect(addr1).tip(addr2.address, tipAmount, message))
                .to.emit(token, "TipSent")
                .withArgs(addr1.address, addr2.address, tipAmount, message);

            // Check balances
            expect(await token.balanceOf(addr2.address)).to.equal(tipAmount);
            expect(await token.balanceOf(addr1.address)).to.equal(0);
        });

        it("Should fail when trying to tip with insufficient balance", async function () {
            const tipAmount = ethers.parseEther("100");
            const message = "Great session!";

            await expect(
                token.connect(addr1).tip(addr2.address, tipAmount, message)
            ).to.be.revertedWith("Insufficient balance");
        });

        it("Should fail when trying to tip zero address", async function () {
            const tipAmount = ethers.parseEther("100");
            const message = "Great session!";

            await expect(
                token.tip(ethers.ZeroAddress, tipAmount, message)
            ).to.be.revertedWith("Cannot tip zero address");
        });

        it("Should fail when trying to tip zero amount", async function () {
            const message = "Great session!";

            await expect(
                token.tip(addr1.address, 0, message)
            ).to.be.revertedWith("Tip amount must be greater than 0");
        });
    });
}); 