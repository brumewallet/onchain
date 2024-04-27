// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Token } from "./Token.sol";

contract Claimer is Ownable {

    /**
     * Token
     */
    Token public token = Token(address(0x0));

    /**
     * Balances
     */
    mapping(address => uint256) public balanceOf;

    /**
     * Create a claimer with a predefined set of targets and values
     */
    constructor(address[] memory targets, uint256[] memory values)
        Ownable(_msgSender())
    {
        for (uint256 i = 0; i < targets.length; i++) {
            balanceOf[targets[i]] = values[i];
        }
    }

    /**
     * Approve to transfer tokens to target
     */
    function approve(address target) public onlyOwner {
        uint256 value = balanceOf[target];
        balanceOf[target] = 0;
        token.transfer(target, value);
    }

}