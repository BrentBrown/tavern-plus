const { expect } = require("chai");

describe("TavernGoldToken", function () {
  let GoldToken, goldToken, owner, addr1, addr2;

  beforeEach(async function () {
    GoldToken = await ethers.getContractFactory("TavernGoldToken");
    [owner, addr1, addr2, _] = await ethers.getSigners();
    goldToken = await GoldToken.deploy(1000);
  });

  it("Should assign the total supply of tokens to the owner", async function () {
    const ownerBalance = await goldToken.balanceOf(owner.address);
    expect(await goldToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Should transfer tokens between accounts", async function () {
    await goldToken.transfer(addr1.address, 50);
    const addr1Balance = await goldToken.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(50);

    await goldToken.connect(addr1).transfer(addr2.address, 50);
    const addr2Balance = await goldToken.balanceOf(addr2.address);
    expect(addr2Balance).to.equal(50);
  });

  it("Should fail if sender doesn't have enough tokens", async function () {
    const initialOwnerBalance = await goldToken.balanceOf(owner.address);
    await expect(
      goldToken.connect(addr1).transfer(owner.address, 1)
    ).to.be.reverted;
    expect(await goldToken.balanceOf(owner.address)).to.equal(
      initialOwnerBalance
    );
  });
}); 