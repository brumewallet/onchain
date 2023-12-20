# Allocation Token

A dynamic-supply token that allows for debt-based allocation and arbitrage, in order to maximize market efficiency and minimize attack surface.

## TLDR

The token is an ERC20 but with an owner (DAO, timelocked DHAO, or timelocked multisig).

The owner is able to:
- Get debt by minting tokens (timelocked)
- Pay debt by burning tokens

In other words:
- Borrowing "money" from the token holders by increasing the supply (a.k.a investment)
- Giving "money" back to the token holders by reducing the supply (a.k.a dividends)

The owner can propose to mint some amount of tokens, which can be only be executed after some delay in order to let the token market vote.

The owner can then use the minted tokens at its sole discretion to invest and generate revenue that will be given back to the token holders.

## Goals and non-goals

- Not preallocated
- Only provides a way to allocate funds
- Achieve a "market vote" thanks to timelocked operations
- Low code attack surface

## Code

```solidity
contract Token is ERC20, Ownable {
  /**
   * The owner SHOULD be timelocked to prevent rugpull
   */
  address public owner;

  /**
   * Mint `amount` of tokens to `receiver`
   */
  function mint(uint256 amount, address receiver) external onlyOwner;

  /**
   * Burn `amount` of tokens from the sender
   */
  function burn(uint256 amount) external;

}
```

## Example

ExampleDHAO's head proposes a budget for the month of September.

An investment of 1k tokens (=100k USD) will be used for:
- Paying developers
- Paying for ads on social medias
- Paying the hosting for the dapp

A revenue of 1.1k tokens (=110k USD) is expected to come from:
- People using the protocol and paying fees
- Companies paying for ads on the dapp

During the DHAO timelock period, the token market can "vote" this proposal, people can buy the token to show agreement, or sell it to show disagreement.

After that period, the head can mint the 1k tokens, and use it as defined in the budget.

If people largely agreed and the token price increased (1k tokens > 100k USD), the multisig can use the minted tokens to:
- Execute the expected actions
- Hold/stake/invest/burn the excess tokens

If people largely disagreed and the token price decreased (1k token < 100k USD), the multisig has to reconsider its budget by:
- Paying less ads on social medias
- Using holded/staked tokens from previous months
- Not buying a Lamborghini for the founders
- Making a new budget proposal that people will agree on

The head is then accountable for any actions done with the tokens, and any failure to do so will affect the token price, and thus future budgets, and thus the sustainability of the head.

In order to pay developers, the head sells some tokens for USDC (e.g. on Uniswap), and sends them through its legal entity.

## Motivation

Provide a way to allocate debt.

## FAQ

### Where is the liquidity?

Unallocated liquidity is wherever the token holders sent their liquidity to (e.g. liquidity pools on Uniswap, LBP contract, crowdfunding contract, centralized exchange)

Allocated liquidity is wherever the owner sent it to (e.g. the owner stakes it on some staking protocol in order to generate revenue)

### What prevents the owner from rugpulling?

If the owner attempts to allocate more than necessary for its functions, the market has a safe delay to disagree and sell the token, or replace the head if the owner is a DHAO.

If the owner has already allocated liquidity, let's say 0.1% of the supply, he can only rugpull that 0.1%.

### Is the token inflationary or deflationary?

It is expected to be inflationary at the start of the project, as many investments are done.

The token price will reflect that inflation, but the speculation of future ROI can outweight it.

When the project becomes cost-effective, the burn/mint ratio will increase and the token will become deflationary.

### Is the token a security?

Probably yes if the owner is a single person or company, probably no if the owner is a DAO/DHAO.

### When are tokens burnt?

Tokens are typically burnt when the project gets some revenue (e.g. protocol fees).
