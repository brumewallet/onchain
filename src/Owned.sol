// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

Owned constant owned = Owned(address(0xd6cCd11a09e616e9F3C24c13F53d62BB1337af3F));
Dummy constant dummy = Dummy(address(0x52d49596757350c0f4423Beaf4420363Fb502E2E));

contract Dummy {

    fallback() external { }

}

contract Owner {

    Ownable public ownable;

    constructor(
        Ownable ownable_
    ) {
        ownable = ownable_;

        owned.mint(msg.sender);
    }

    function implementation() external view returns (address) {
        return address(ownable);
    }

    fallback() external payable {
        require(msg.sender == owned.ownerOf(uint256(uint160(address(this)))));

        address(dummy).delegatecall("");

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := call(gas(), sload(ownable.slot), callvalue(), 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

}

contract Owned is ERC721, ERC721URIStorage, ERC721Enumerable {

    constructor()
        ERC721("Owned", "OWNED")
    {}

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool) {
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

    function mint(address to) public {
        _mint(to, uint256(uint160(msg.sender)));
    }

}