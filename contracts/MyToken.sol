// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Governance is Ownable, ERC20, ERC20Permit {

    /*
     * The original token contract
     */
    IERC20 public constant token = IERC20(0x0000000000000000000000000000000000000000);
    
    /*
     * The timelock delay in seconds
     */
    uint256 public delay = 2 * 7 * 24 * 60 * 60;

    /*
     * Vote by token holder
     */
    mapping(address => address) public voteOf;

    /*
     * Power by candidate
     */
    mapping(address => uint256) public powerOf;
    
    constructor(address initialOwner)
        ERC20("Voting Brume", "VBRUME")
        Ownable(initialOwner)
        ERC20Permit("Voting Brume")
    {}

    function _update(address from, address to, uint256 value) internal virtual override  {
        super._update(from, to, value);

        if (from != address(0)) {
            powerOf[voteOf[from]] -= value;
        }

        if (to != address(0)) {
            powerOf[voteOf[to]] += value;
        }
    }

    /* 
     * Delegate your voting power to `voted`
     */
    function vote(address voted) public {
        address previousVoted = voteOf[_msgSender()];

        if (previousVoted != address(0)) {
            powerOf[previousVoted] -= balanceOf(_msgSender());
        }

        voteOf[_msgSender()] = voted;

        if (voted != address(0)) {
            powerOf[voted] += balanceOf(_msgSender());
        }
    }

    function acquire() public {
        if (owner() != address(0)) {
            require(powerOf[owner()] < powerOf[_msgSender()], "Governance: insufficient power");
        }

        _transferOwnership(_msgSender());
    }

    function wrap(uint256 amount) public {
        token.transferFrom(_msgSender(), address(this), amount);
        _mint(_msgSender(), amount);
    }

    function unwrap(uint256 amount) public {
        _burn(_msgSender(), amount);
        token.transfer(_msgSender(), amount);
    }


}
