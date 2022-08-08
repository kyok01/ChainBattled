// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Props {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    mapping(uint256 => Props) public tokenIdToProps;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        (string memory level, string memory speed, string memory strength, string memory life) = getProps(tokenId);
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            level,
            ",Speed: ",
            speed,
            ",Strength: ",
            strength,
            ",Life: ",
            life,
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getProps(uint256 tokenId) public view returns (string memory,string memory, string memory, string memory) {
        Props memory props = tokenIdToProps[tokenId];
        return (props.level.toString(), props.speed.toString(), props.strength.toString(), props.life.toString());
    }

    /**
     * @dev create random number for nft props
     */

    function createRandom(uint range, uint number) public view returns(uint){
        return uint(blockhash(block.number-number)) % range;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        uint256 randamSpeed = createRandom(100,1);
        uint256 randamStrength = createRandom(100,2);
        uint256 randamLife = createRandom(100,3);

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);
        tokenIdToProps[newItemId] = Props(0, randamSpeed, randamStrength, randamLife);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "not exist");
        require(ownerOf(tokenId) == msg.sender, "you are not an owner");

        Props memory newProps;
        Props memory currentProps = tokenIdToProps[tokenId];
        
        newProps = Props(currentProps.level+1, currentProps.speed+1, currentProps.strength+1, currentProps.life+1);
        tokenIdToProps[tokenId] = newProps;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
