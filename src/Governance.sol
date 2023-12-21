// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

contract Governance is Ownable, ERC20, ERC20Wrapper, ERC20Votes {
    
    /**
     * @dev The timelock delay in seconds.
     */
    uint256 public delay;

    /**
     * @dev A pending proposal.
     */
    struct Proposal {
        uint256 callshash;
        uint256 timestamp;
    }

    /**
     * @dev The pending proposal.
     */
    Proposal public proposal;

    /**
     * @dev You don't have enough power to acquire the governance.
     */
    error GovernanceInsufficientPower(address account);

    /**
     * @dev You attempted to execute an invalid proposal.
     */
    error GovernanceInvalidExecution(uint256 callshash);
    
    /**
     * @dev You attempted to execute a proposal too early.
     */
    error GovernancePrematureExecution(uint256 timestamp);

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error GovernanceUnauthorizedAccount(address account);

    /**
     * @dev This operation is disabled for security reasons.
     */
    error GovernanceDisabledOperation();
    
    constructor(IERC20 token_, address owner_, uint256 delay_)
        Ownable(owner_)
        ERC20Wrapper(token_)
        ERC20("Voting Brume", "VBRUME")
        EIP712("Voting Brume", "v1")
    {
        delay = delay_;
    }
 
    /**
     * @dev Use ERC20Wrapper decimals.
     */
    function decimals() public view override(ERC20, ERC20Wrapper) returns (uint8) {
        return ERC20Wrapper.decimals();
    }

    /**
     * @dev Use ERC20Votes to update the voting power.
     */
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        ERC20Votes._update(from, to, value);
    }

    /**
     * @dev Disable delegate-by-signature to avoid phishing and replay attacks.
     */
    function delegateBySig(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) public pure override(Votes) {
        revert GovernanceDisabledOperation();
    }

    /**
     * @dev Disable ownership transfers to avoid weird things from happening.
     */
    function transferOwnership(address) public pure override(Ownable) {
        revert GovernanceDisabledOperation();
    }

    /**
     * @dev Acquire the governance if you have the most voting power.
     */
    function acquire() public {
        if (owner() != address(0)) {
            if (getPastVotes(_msgSender(), block.number - 1) < getVotes(owner())) {
              revert GovernanceInsufficientPower(_msgSender());
            }
        }

        _transferOwnership(_msgSender());
    }

    /**
     * @dev Increase your voting power by wrapping `amount` of your original tokens.
     */
    function deposit(uint256 amount) public {
        depositFor(_msgSender(), amount);
    }

    /**
     * @dev Increase your voting power by wrapping all your original tokens.
     */
    function depositAll() public {
        depositFor(_msgSender(), balanceOf(_msgSender()));
    }

    /**
     * Decrease your voting power by unwrapping `amount` of your original tokens.
     */
    function withdraw(uint256 amount) public {
        withdrawTo(_msgSender(), amount);
    }

    /**
     * Decrease your voting power by unwrapping all your original tokens.
     */
    function withdrawAll() public {
        withdrawTo(_msgSender(), balanceOf(_msgSender()));
    }

    /**
     * @dev Hash a set of transactions.
     */
    function hashOf(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas)));
    }

    /**
     * @dev Propose a new set of transactions.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public onlyOwner {
        /**
         * @dev Set the pending proposal and replace the previous one.
         */
        proposal = Proposal(hashOf(targets, values, calldatas), block.timestamp);
    }

    /**
     * @dev Execute the pending proposal.
     */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) public onlyOwner {
        uint256 callshash = hashOf(targets, values, calldatas);

        /**
         * @dev Check if the proposal is the same.
         */
        if (callshash != proposal.callshash) {
            revert GovernanceInvalidExecution(callshash);
        }

        /**
         * @dev Check if the proposal is ready to be executed.
         */
        if (block.timestamp < (proposal.timestamp + delay)) {
            revert GovernancePrematureExecution(block.timestamp);
        }

        /**
         * @dev Reset the proposal.
         */
        proposal = Proposal(0, 0);

        /**
         * @dev Execute the proposal.
         */
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            Address.verifyCallResult(success, returndata);
        }
    }

    /**
     * @dev Throws if called by any account other than this contract.
     */
     modifier onlySelf() {
        _checkSelf();
        _;
    }

    /**
     * @dev Throws if the sender is not this contract.
     */
    function _checkSelf() internal view {
        if (address(this) != _msgSender()) {
            revert GovernanceUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Set the timelock delay.
     */
    function setDelay(uint256 _delay) public onlySelf {
        delay = _delay;
    }

}
