const { expect } = require("chai");

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
    it("Should set the correct owner", async function () {
      expect(await contract.owner()).to.equal(owner.address);
    });
  });

  describe("Create components and backgrounds", function () {
    it("Should create a new component", async function () {
      await contract.createImageComponent("https://example.com/component1.png");
      const component = await contract.imageComponents(0);
      expect(component.uri).to.equal("https://example.com/component1.png");
    });

    it("Should create a new background", async function () {
      await contract.createBackground("https://example.com/background1.png");
      const background = await contract.backgrounds(0);
      expect(background.uri).to.equal("https://example.com/background1.png");
    });
  });

  describe("Compose and update images", function () {
    beforeEach(async function () {
      await contract.createImageComponent("https://example.com/component1.png");
      await contract.createImageComponent("https://example.com/component2.png");
      await contract.createBackground("https://example.com/background1.png");
      await contract.createBackground("https://example.com/background2.png");
    });

    it("Should compose a new image", async function () {
      await contract.composeImage([0, 1], 2);
      const composedImage = await contract.composedImages(3);
      expect(composedImage.componentIds).to.deep.equal([0, 1]);
      expect(composedImage.backgroundId).to.equal(2);
    });

    it("Should update the background of an existing image", async function () {
      await contract.composeImage([0, 1], 2);
      await contract.connect(addr1).updateBackground(3, 3);
      const composedImage = await contract.composedImages(3);
      expect(composedImage.backgroundId).to.equal(3);
    });
  });
});
