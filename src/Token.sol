// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is Ownable, ERC20, ERC20Burnable {

    constructor(address initialOwner)
        ERC20("Brume", "BRUME")
        Ownable(initialOwner)
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function approveToOwner(uint256 amount) public {
        approve(owner(), amount);
    }

    function approveAll(address spender) public {
        approve(spender, balanceOf(_msgSender()));
    }

    function approveAllToOwner() public {
        approveAll(owner());
    }

}