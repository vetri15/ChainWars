// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChainWars is ERC721,Ownable {

    event AmountwithDrawn(uint256 timeOfWithdrawl);

    uint private _tokenIdCount;
    using Strings for uint256;

    struct playerStats{
        uint256 level;
        uint256 hp;
        uint256 strength;
        uint256 speed;
        bool isInit;
    }

    mapping(uint256 => playerStats) public tokenIdToPlayerStats;
    mapping (uint256 => string) private _tokenURIs;

    constructor() ERC721("ChainWars", "CWRS") Ownable(msg.sender) {

    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

    function mint() public payable {
        //min 0.001 ETH
        require(msg.value > 1000000000000000);
        _tokenIdCount++;
        uint256 newItemId = _tokenIdCount;
        _safeMint(msg.sender, newItemId);
        tokenIdToPlayerStats[newItemId] = playerStats(1 , 1 , 1 , 1, true);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function withdraw() public onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if(success){
            emit AmountwithDrawn(block.timestamp);
        }else{
            revert();
        }
    }

    function train(uint256 tokenId) public payable{
        require(ownerOf(tokenId) != address(0));
        require(ownerOf(tokenId) == msg.sender, "Only owner can train their NFT");
        //min 0.001 ETH
        require(msg.value > 1000000000000000);
        tokenIdToPlayerStats[tokenId].level = tokenIdToPlayerStats[tokenId].level + getRandomTimeBased();
        tokenIdToPlayerStats[tokenId].hp = tokenIdToPlayerStats[tokenId].hp + getRandomBlockBased();
        tokenIdToPlayerStats[tokenId].strength = tokenIdToPlayerStats[tokenId].strength + getRandomTimeBased();
        tokenIdToPlayerStats[tokenId].speed = tokenIdToPlayerStats[tokenId].speed + getRandomBlockBased();
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function getRandomTimeBased() private view returns (uint256){
        uint256 timeNow = block.timestamp;
        uint256 randomWord = uint256(keccak256(abi.encodePacked(timeNow)));
        uint256 result = (randomWord % 10) + 1;
        return result;
    }

    function getRandomBlockBased() private view returns (uint256){
        bytes32 blockHash = blockhash(block.number-1);
        uint256 randomWord = uint256(keccak256(abi.encodePacked(blockHash)));
        uint256 result = (randomWord % 10) + 1;
        return result;
    }

    function generateCharacter(uint256 tokenId) public view returns(string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="DarkSlateGray" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",getLevel(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Hp: ",getHp(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            ));
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Wars #', tokenId.toString(), '",',
                '"description": "Cool Chain Wars",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function getLevel(uint256 tokenId) public view returns (string memory) {
        uint256 level = tokenIdToPlayerStats[tokenId].level;
        return level.toString();
    }

    function getHp(uint256 tokenId) public view returns (string memory) {
        uint256 hp = tokenIdToPlayerStats[tokenId].hp;
        return hp.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdToPlayerStats[tokenId].strength;
        return strength.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 speed = tokenIdToPlayerStats[tokenId].speed;
        return speed.toString();
    }
}