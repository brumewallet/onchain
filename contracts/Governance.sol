// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC6372.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Governance is Ownable, ERC20, IERC6372 {

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

    /*
     * A pending proposal
     */
    struct Proposal {
        uint256 callshash;
        uint256 timestamp;
    }

    /*
     * The pending proposal
     */
    Proposal public proposal;

    /*
     * You don't have enough power to acquire the governance
     */
    error GovernanceInsufficientPower(address account);

    /*
     * You attempted to execute an invalid proposal
     */
    error GovernanceInvalidExecution(uint256 callshash);
    
    /*
     * You attempted to execute a proposal too early
     */
    error GovernancePrematureExecution(uint256 timestamp);
    
    constructor(address initialOwner)
        ERC20("Voting Brume", "VBRUME")
        Ownable(initialOwner)
    {}

    /*
     * Recompute voting power when a transfer happens
     */
    function _update(address from, address to, uint256 value) internal override  {
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

    /*
     * Acquire the governance if you have the most voting power
     */
    function acquire() public {
        if (owner() != address(0)) {
            if (powerOf[_msgSender()] < powerOf[owner()]) {
              revert GovernanceInsufficientPower(_msgSender());
            }
        }

        _transferOwnership(_msgSender());
    }

    /*
     * Increase your voting power by wrapping `amount` of your original tokens
     */
    function wrap(uint256 amount) public {
        token.transferFrom(_msgSender(), address(this), amount);
        _mint(_msgSender(), amount);
    }

    /*
     * Decrease your voting power by unwrapping `amount` of your original tokens
     */
    function unwrap(uint256 amount) public {
        _burn(_msgSender(), amount);
        token.transfer(_msgSender(), amount);
    }

    /*
     * Hash a set of transactions
     */
    function hashOf(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas)));
    }

    /*
     * Propose a new set of transactions
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public onlyOwner {
        /*
         * Set the pending proposal and replace the previous one
         */
        proposal = Proposal(hashOf(targets, values, calldatas), block.timestamp);
    }

    /*
     * Execute the pending proposal
     */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public onlyOwner {
        uint256 callshash = hashOf(targets, values, calldatas);

        /*
         * Check if the proposal is the same
         */
        if (callshash != proposal.callshash) {
            revert GovernanceInvalidExecution(callshash);
        }

        /*
         * Check if the proposal is ready to be executed
         */
        if (block.timestamp < (proposal.timestamp + delay)) {
            revert GovernancePrematureExecution(block.timestamp);
        }

        /*
         * Execute the proposal
         */
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            Address.verifyCallResult(success, returndata);
        }

        /*
         * Reset the proposal
         */
        proposal = Proposal(0, 0);
    }

    /*
     * Set the timelock delay (can only be called from a proposal)
     */
    function setDelay(uint256 _delay) private {
        delay = _delay;
    }

    /*
     * IERC6372
     */
    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    /*
     * IERC6372
     */
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

}
