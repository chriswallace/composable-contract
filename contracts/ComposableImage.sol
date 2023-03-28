pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ComposableImage is ERC721, Ownable {
    event ImageComposed(uint256 tokenId, uint256[] componentIds, uint256 backgroundId);

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct ImageComponent {
        uint256 componentId;
        string uri;
        bool exists; // Add this line
    }

    struct ComposedImage {
        uint256[] componentIds;
        uint256 backgroundId;
    }

    mapping(uint256 => ImageComponent) public imageComponents;
    mapping(uint256 => ComposedImage) public composedImages;
    mapping(uint256 => ImageComponent) public backgrounds;

    constructor() ERC721("ComposableImage", "CIMG") {
        _tokenIdCounter.increment(); // Add this line
    }

    function createImageComponent(string memory uri) public onlyOwner returns (uint256) {
        uint256 componentId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        imageComponents[componentId] = ImageComponent(componentId, uri, true); // Add true for exists
        return componentId;
    }

    function createBackground(string memory uri) public onlyOwner returns (uint256) {
        uint256 backgroundId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        backgrounds[backgroundId] = ImageComponent(backgroundId, uri, true); // Add true for exists
        return backgroundId;
    }

    function composeImage(uint256[] memory componentIds, uint256 backgroundId) public returns (uint256) {
        require(backgrounds[backgroundId].exists, "Invalid background ID"); // Update this line

        uint256 composedImageId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        composedImages[composedImageId] = ComposedImage(componentIds, backgroundId);
        _safeMint(msg.sender, composedImageId);
        // Emit the ImageComposed event
        emit ImageComposed(composedImageId, componentIds, backgroundId); // Add this line
        return composedImageId;
    }

    function getComposedImage(uint256 tokenId) public view returns (uint256[] memory, uint256) {
        ComposedImage storage composedImage = composedImages[tokenId];
        return (composedImage.componentIds, composedImage.backgroundId);
    }

    function updateBackground(uint256 tokenId, uint256 newBackgroundId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not owner nor approved");
        require(backgrounds[newBackgroundId].componentId >= 1, "Invalid background ID");

        composedImages[tokenId].backgroundId = newBackgroundId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        ComposedImage storage composedImage = composedImages[tokenId];
        string memory base = "data:application/json;charset=utf-8,";
        string memory json = '{"name":"Composed Image", "description":"A composable image", "background_uri":"';
        json = string(abi.encodePacked(json, backgrounds[composedImage.backgroundId].uri, '", "components":['));
        for (uint256 i = 0; i < composedImage.componentIds.length; i++) {
            ImageComponent storage component = imageComponents[composedImage.componentIds[i]];
            json = string(abi.encodePacked(json, '{ "component_id":', Strings.toString(component.componentId), ', "uri":"', component.uri, '"}'));
            if (i < composedImage.componentIds.length - 1) {
                json = string(abi.encodePacked(json, ','));
            }
        }
        json = string(abi.encodePacked(json, ']}'));
        return string(abi.encodePacked(base, json));
    }
}