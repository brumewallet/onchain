// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

Owned constant owned = Owned(address(0xd6cCd11a09e616e9F3C24c13F53d62BB1337af3F));

contract Owner {

    address public implementation;

    constructor(
        address implementation_
    ) {
        implementation = implementation_;

        owned.mint(msg.sender);

        return;
    }

    function dontcallme() external {
       assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), address(), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function call() internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := call(gas(), sload(implementation.slot), callvalue(), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function staticcall() internal view {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := staticcall(gas(), sload(implementation.slot), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable { 
        if (msg.sender == address(this)) {
            return;
        }

        if (msg.sender == owned.ownerOf(uint256(uint160(address(this))))) {
            return call();
        }

        return staticcall();
    }

    fallback() external payable {
        if (msg.sender == address(this)) {
            return;
        }

        if (msg.sender == owned.ownerOf(uint256(uint160(address(this))))) {
            return call();
        }

        return staticcall();
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