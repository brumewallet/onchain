// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { Math } from "@openzeppelin/contracts/utils/math//Math.sol";

library MyBytes {

    function slice(bytes memory data, uint256 start, uint256 end) public pure returns (bytes memory) {
        bytes memory result = new bytes(end - start);
        
        for (uint256 i = start; i < end; i++) {
            result[i - start] = data[i];
        }
        
        return result;
    }

}

library MyStrings {
    using SafeCast for *;

    bytes16 private constant HEX_DIGITS = "0123456789abcdef";

    uint8 private constant ADDRESS_LENGTH = 20;

    error StringsInsufficientHexLength(uint256 value, uint256 length);

    error StringsInvalidChar();

    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        uint256 hashValue;

        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
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

    function tokenURI(uint256 tokenId) public pure override(ERC721, ERC721URIStorage) returns (string memory) {
        bytes memory addr = bytes(MyStrings.toChecksumHexString(address(uint160(tokenId))));
        
        bytes memory svg = abi.encodePacked(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 512 512\">",
                "<style xmlns=\"http://www.w3.org/2000/svg\">",
                    ".base { fill: white; font-family: sans-serif; font-size: 56px; }",
                "</style>",
                "<rect xmlns=\"http://www.w3.org/2000/svg\" width=\"100%\" height=\"100%\" fill=\"black\" />",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"20%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 0, 6),
                "</text>",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"30%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 6, 12),
                "</text>",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"40%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 12, 18),
                "</text>",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"50%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 18, 24),
                "</text>",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"60%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 24, 30),
                "</text>",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"70%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 30, 36),
                " </text>",
                "<text xmlns=\"http://www.w3.org/2000/svg\" x=\"50%\" y=\"80%\" class=\"base\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    MyBytes.slice(addr, 36, 42),
                "</text>",
            "</svg>"
        );

        bytes memory data = abi.encodePacked(
            "{",
                "\"name\": \"", addr, "\",",
                "\"description\": \"", addr, "\",",
                "\"image\": \"", abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)), "\"",
            "}"
        );
        
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(data)));
    }

    function mint(address to) public {
        _mint(to, uint256(uint160(msg.sender)));
    }

}