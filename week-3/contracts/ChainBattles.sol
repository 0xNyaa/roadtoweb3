// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    mapping(uint256 => Character) public tokenIdToCharacters;

    struct Character {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        Character memory char = tokenIdToCharacters[tokenId];
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            char.level.toString(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            char.speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            char.strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            char.life.toString(),
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

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataUri = abi.encodePacked(
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
                    Base64.encode(dataUri)
                )
            );
    }

    // pseudo RNG from 0 to limit
    function getRandomInt(uint256 seed, uint256 limit)
        internal
        view
        returns (uint256)
    {
        uint256 num = uint256(
            keccak256(
                abi.encodePacked(
                    seed,
                    block.difficulty,
                    block.timestamp,
                    block.coinbase
                )
            )
        );
        return num % limit;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        // increment user's balance and set `_owners[newItemId] = msg.sender` in ERC721.sol
        _safeMint(msg.sender, newItemId);
        tokenIdToCharacters[newItemId] = Character(
            1,
            getRandomInt(0, 10),
            getRandomInt(1, 10),
            getRandomInt(2, 100)
        );
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        // unnecessary since ownerOf already checks this
        // require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "Only owner can train");

        Character memory char = tokenIdToCharacters[tokenId];
        char.level++;
        char.speed += getRandomInt(0, 5);
        char.strength += getRandomInt(1, 5);
        char.life += getRandomInt(2, 10);

        tokenIdToCharacters[tokenId] = char;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
