// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Blog is Ownable {

    mapping (uint256 => string) public posts;

    uint256 public length = 0;

    constructor()
        Ownable(_msgSender())
    {}

    event Created(uint256 indexed index, string text);

    function create(string calldata uri) public onlyOwner {
        uint256 index = length++;

        posts[index] = uri;

        emit Created(index, uri);
    }

    event Modified(uint256 indexed index, string uri);

    function modify(uint256 index, string calldata uri) public onlyOwner {
        posts[index] = uri;

        emit Modified(index, uri);
    }

}