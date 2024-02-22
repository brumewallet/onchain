// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is Ownable, ERC20, ERC20Burnable {
    constructor(address initialOwner) ERC20("Brume", "BRUME") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function approveToOwner(uint256 amount) external {
        approve(owner(), amount);
    }

    function approveAll(address spender) external {
        approve(spender, balanceOf(_msgSender()));
    }

    function approveAllToOwner() external {
        approve(owner(), balanceOf(_msgSender()));
    }
}
