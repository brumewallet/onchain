// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721Royalty } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

contract Art is Ownable, ERC721, ERC721URIStorage, ERC721Enumerable, ERC721Royalty {

    constructor()
        ERC721("Brume Art", "BRUME")
        Ownable(_msgSender())
    {}

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function setDefaultRoyalty(uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(owner(), feeNumerator);
    }

    function deleteDefaultRoyalty() public onlyOwner {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) public onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function resetTokenRoyalty(uint256 tokenId) public onlyOwner {
        _resetTokenRoyalty(tokenId);
    }

    function setTokenURI(uint256 tokenId, string calldata _tokenURI) public onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
    }

}

contract Multiminter is Ownable {
    
    Art public art;

    constructor(
        Art art_
    )
        Ownable(_msgSender())
    {
        art = art_;
    }

    function dispose() public onlyOwner {
        art.transferOwnership(owner());
    }

    function batch(uint256[] calldata ids, address[] calldata tos, string[] calldata uris) public onlyOwner {
        for (uint8 i = 0; i < ids.length; i++){
            art.mint(tos[i], ids[i]);
            art.setTokenURI(ids[i], uris[i]);
        }
    }

}