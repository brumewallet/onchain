# Safe Claimer

A token claiming contract that allows its owner to approve sending an immutable predefined amount of tokens to an immutable predefined set of addresses.

## Motivation

We want a safe way to send an immutable predefined amount of tokens to an immutable predefined set of addresses only after approval by the contract owner, even if the owner becomes compromised. The worst scenario is the malicious owner not approving some addresses and thus locking tokens in the contract.

## Pseudo-code

```solidity
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
```

## FAQ

### Why not just mint tokens to the owner and let him manually transfer tokens?

This contracts prevents the owner from holding the tokens. During the time between the mint and the approval, the owner could become compromised. The owner could then use tokens like he wants. This even more important if the token has power such as voting in a DAO.