// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../contracts/Governance.sol";
import "../contracts/Token.sol";

contract GovernanceTest is Test {
    Governance public governance;
    Token public originalToken;

    uint256 public constant INITIAL_VOTING_DELAY = 1209600;
    uint256 public constant VOTER_1_INITIAL_AMOUNT = 10000000000000000000;
    uint256 public constant VOTER_2_INITIAL_AMOUNT = 150000000000000000000;
    uint256 public constant VOTER_3_INITIAL_AMOUNT = 450000000000000000000;

    address public constant CREATOR = 0xe8AE3F2bFED29d02FE10D453C7098A73b9a2747C;
    address public constant INITIAL_OWNER = 0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326;
    address public constant VOTER_1 = 0x25F47D6CBB3782FA92A68C067727eb890269b2C8;
    address public constant VOTER_2 = 0x52a9EEf606115f488abd34194C73256F982A2Ab9;
    address public constant VOTER_3 = 0x5a65B0aA22f441Fd05eB0e81ff0dA6ecF07C8d8e;

    address[] public proposalTargets1 = [VOTER_1];
    uint256[] public values1 = [1234];
    bytes[] public calldatas1 = new bytes[](2);

    /////////////////////////////

    // SETUP

    function setUp() public {
        vm.startPrank(CREATOR);

        originalToken = new Token(CREATOR);
        originalToken.mint(VOTER_1, VOTER_1_INITIAL_AMOUNT);
        originalToken.mint(VOTER_2, VOTER_2_INITIAL_AMOUNT);
        originalToken.mint(VOTER_3, VOTER_3_INITIAL_AMOUNT);

        governance = new Governance(originalToken, INITIAL_OWNER, INITIAL_VOTING_DELAY);

        vm.stopPrank();
    }

    /////////////////////////////

    // Basic wrap
    function testBasicWrap() public {
        vm.startPrank(VOTER_1);
        originalToken.approve(address(governance), VOTER_1_INITIAL_AMOUNT);
        governance.wrap(VOTER_1_INITIAL_AMOUNT);
        vm.stopPrank();

        assertEq(originalToken.balanceOf(VOTER_1), 0);
        assertEq(governance.balanceOf(VOTER_1), VOTER_1_INITIAL_AMOUNT);
    }

    // Basic unwrap
    function testBasicUnwrap() public {
        vm.startPrank(VOTER_1);
        originalToken.approve(address(governance), VOTER_1_INITIAL_AMOUNT);
        governance.wrap(VOTER_1_INITIAL_AMOUNT);
        governance.unwrap(VOTER_1_INITIAL_AMOUNT);
        vm.stopPrank();

        assertEq(originalToken.balanceOf(VOTER_1), VOTER_1_INITIAL_AMOUNT);
        assertEq(governance.balanceOf(VOTER_1), 0);
    }

    // Propose by owner
    function testProposeByOwner() public {
        vm.prank(INITIAL_OWNER);
        governance.propose(proposalTargets1, values1, calldatas1);
        (uint256 callshash,) = governance.proposal();
        
        assertEq(governance.hashOf(proposalTargets1, values1, calldatas1), callshash);
    }

    // Propose by non-owner
    function testProposeByNonOwner() public {
        vm.prank(VOTER_1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, VOTER_1));
        governance.propose(proposalTargets1, values1, calldatas1);
    }

    /////////////////////////////
}
