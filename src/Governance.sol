// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Governance is Ownable, ERC20Votes, ERC20Burnable {

    /**
     * @dev The original token contract.
     */
    IERC20 public immutable token;
    
    /**
     * @dev The timelock delay in seconds.
     */
    uint256 public delay;

    /**
     * @dev Vote by token holder.
     */
    mapping(address => address) public voteOf;

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
    
    constructor(IERC20 token_, address owner_, uint256 delay_)
        ERC20("Voting Brume", "VBRUME")
        EIP712("Voting Brume", "v1")
        Ownable(owner_)
    {
      token = token_;
        delay = delay_;
    }
 
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
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
    function wrap(uint256 amount) public {
        SafeERC20.safeTransferFrom(token, _msgSender(), address(this), amount);
        _mint(_msgSender(), amount);
    }

    /**
     * Decrease your voting power by unwrapping `amount` of your original tokens.
     */
    function unwrap(uint256 amount) public {
        _burn(_msgSender(), amount);
        SafeERC20.safeTransfer(token, _msgSender(), amount);
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
         * @dev Execute the proposal.
         */
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            Address.verifyCallResult(success, returndata);
        }

        /**
         * @dev Reset the proposal.
         */
        proposal = Proposal(0, 0);
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
