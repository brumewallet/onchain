// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is Ownable, ERC20, ERC20Burnable {

    constructor(
        string memory name_,
        string memory symbol_
    )
        ERC20(name, symbol)
        Ownable(_msgSender())
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
        approve(owner(), balanceOf(_msgSender()));
    }

}

contract Batcher is Ownable {

    Token token;

    constructor(
        Token token_
    )
        Ownable(_msgSender())
    {
        token = token_;
    }

    function batch(address[] calldata tos, uint256[] calldata amounts) public onlyOwner {
        for (uint8 i = 0; i < tos.length; i++) {
            token.mint(tos[i], amounts[i]);
        }
    }

    function dispose() public onlyOwner {
        token.transferOwnership(owner());
    }

}