// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Database {

    mapping (bytes4 => string[]) array;
    mapping (bytes4 => mapping(string => bool)) set; 

    error AlreadyKnown();

    function add(string calldata text) public {
        bytes4 hash = bytes4(keccak256(bytes(text)));

        if (set[hash][text])
            revert AlreadyKnown();

        array[hash].push(text);
        set[hash][text] = true;
    }

    function get(bytes4 hash) public view returns (string[] memory) {
        return array[hash];
    }

}
