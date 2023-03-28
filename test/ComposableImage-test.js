const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComposableImage", function () {
  let ComposableImage;
  let contract;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    ComposableImage = await ethers.getContractFactory("ComposableImage");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    contract = await ComposableImage.deploy();
    await contract.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await contract.owner()).to.equal(owner.address);
    });
  });

  describe("Create and compose image", function () {
    it("Should create image components and compose an image", async function () {
      // Create components
      await contract.createImageComponent("https://example.com/component1.png");
      await contract.createImageComponent("https://example.com/component2.png");

      // Create background
      await contract.createBackground("https://example.com/background1.png");

      // Compose image
      const composeImageTx = await contract.composeImage([1, 2], 3);
      const composeImageReceipt = await composeImageTx.wait();
      const imageComposedEvent = composeImageReceipt.events.find(e => e.event === "ImageComposed");
      const tokenId = imageComposedEvent.args.tokenId;
      const composedImage = await contract.composedImages(tokenId);
      
      const [componentIdsArray, backgroundId] = await contract.getComposedImage(tokenId); // Update this line
      expect(componentIdsArray).to.deep.equal([1, 2]);
      expect(backgroundId).to.equal(3);
    });
  });

  describe("Update background", function () {
    it("Should update the background of an NFT", async function () {
      // Create components
      await contract.createImageComponent("https://example.com/component1.png");
      await contract.createImageComponent("https://example.com/component2.png");
  
      // Create backgrounds
      await contract.createBackground("https://example.com/background1.png");
      await contract.createBackground("https://example.com/background2.png");
  
      // Compose image
      const composeImageTx = await contract.composeImage([1, 2], 3);
      const composeImageReceipt = await composeImageTx.wait();
      const imageComposedEvent = composeImageReceipt.events.find(e => e.event === "ImageComposed");
      const tokenId = imageComposedEvent.args.tokenId;
  
      // Transfer NFT to addr1
      await contract.transferFrom(owner.address, addr1.address, tokenId);
  
      // Update background
      await contract.connect(addr1).updateBackground(tokenId, 4);
      const composedImage = await contract.composedImages(tokenId);

      // Use .toNumber() to convert BigNumber to a regular number
      expect(composedImage.toNumber()).to.equal(4);
    });
  });  
});
