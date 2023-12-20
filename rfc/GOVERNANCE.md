# Decentralized Headed Autonomous Organization

A governance that can continuously vote for an ultimate delegate that will be able to perform some timelocked tasks.

## Summary

Current governance models have become over-engineered and over-bureaucratic.

The old "discrete" voting system poses serious problems of coordination to the voters, which can undermine the decentralization of the organization.

While delegation can mitigate those issues, this new governance aims to go further by establishing an "ultimate delegate", the head.

Since this election is only based on delegation, your vote is "continuous", which means you can switch the head at any time, and it's quorum-less.

This lowers both the attack surface and the number of parameters, only 1 parameter is required to setup this governance: delay.

The recommended delay is 2 weeks, leaving enough time to (re)coordinate in case the delegation chain is compromised.

When combined with an Allocation Token, this governance enables efficient market signalling through Game theory and is closer to Austrian economics than ever before.

The head effectively becomes the "entrepreneur" of the DAO, taking risks with a set of coherent proposals you can either accept or refuse as a whole.

This governance is naturally subject to the Lindy effect, which means the more you were legitimate in the past, the more chances you have to be legitimate in the present.

## Goals and non-goals

- Quorum-less
- Super delegation
- Aim to a consensus
- Avoid voter fatigue
- Low attack surface
- Coherent governance
- Austrian economics
- Game theory
- Lindy effect

## Pseudo-code

```solidity
contract Governance is ERC20 {

  /**
   * The original token contract
   */
  IERC20 public constant token;

  /**
   * The timelock delay in seconds (2 weeks is recommended)
   */
  uint256 public delay = 2 * 7 * 24 * 60 * 60;

  /**
   * Vote by token holder
   */
  mapping(address => address) public voteOf;

  /**
   * Power by candidate (recomputed when `balanceOf` or `voteOf` is changed)
   */
  mapping(address => uint256) public powerOf;

  /**
   * The current head (recomputed when `powerOf` is changed)
   */
  address public head;

  /**
   * Delegate your voting power to `voted`
   */
  function vote(address voted) public;

  /**
   * Increase your voting power by wrapping your original tokens
   */
  function wrap(uint256 amount) public;

  /**
   * Decrease your voting power by unwrapping your original tokens
   */
  function unwrap(uint256 amount) public;

  /**
   * Propose some timelocked transaction
   */
  function propose(...) public onlyHead;

  /**
   * Execute some timelocked transaction proposal
   */
  function execute() public onlyHead onlyExecuteAfterDelay;

}
```

## Continuous vote

In current DAOs, the vote is discrete, someone (public or multisig) makes a proposal, and then you can vote for it during a limited time. If proposals are too frequent, then your voters will have a "voter fatigue". This voter fatigue can be used to attack the DAO, and any countermeasure increases the complexity, creates unintended side-effects, and increase the attack surface (both in terms of Game theory and in terms of code).

For example, I want to propose something that has more chance of success, I make a "dummy" proposal that for sure will be rejected (e.g. rugpull), then just after that I make my "original" proposal. This proposal will have more chance of success since the number of voters will decrease by voter fatigue (e.g. half the people who would have voted won't vote), but my own voting power would not decrease since I will not be subject to this voter fatigue.

On a Game theory perspective, the coordination is harder for "the people" than for an attacker.

You might require that the proposal can only succeed if at least X% of the token holders vote, but this would still be problematic as this number if fully abitrary. What if a large portion of tokens are on liquidity or staking pools? What if some part of the token holders have lost their private key? You may be tempted to adjust this number in real-time, but what parameters should you take into account? This becomes overly complex and increases the attack surface.

You might also add a cooldown to proposals, but would be subject to attacks too (let's spam with "dummy" proposals from multiple accounts to DDoS the DAO by voter fatigue). You might prevent this by forcing to burn/stake tokens to propose, but just like any anti-spam mechanisms, this will always have side-effects, and thus new attack surface (e.g. Sybil attack, coordination issues, etc).

While delegation can mitigate those issues, this new governance aims to go further by establishing an "ultimate delegate", the head.

We would like a single never-ending proposal. If you agree with "the way the DAO is governed" then you vote a sticky "yes", if you disagree then you vote a sticky "no". But for this to work, we need to have someone (typically a multisig) that will represent "the way the DAO is governed" in a coherent manner. Just like before, there is still the concept of proposal and vote, the head makes timelocked transactions as "proposals" and can be ejected at any time at the will of the DAO. But you do not vote for those single proposals, you vote for "the way the DAO is governed", which is the set of coherent proposals. This vote happens continuously with a reduced attack surface (both in terms of Game theory and in terms of code). The current head is simply the delegate with the most voting power, when the current head is ejected, its pending proposal is refused. 

With this continous vote, there is a single proposal, but there can be multiple "attempts" to switch the head.

Voting aside, discrete governances have a complex smart contract interface, which often requires special frontends to be able to vote. Those frontends are subject to all kinds of attacks such as phishing, DNS attacks, supply-chain attacks. This governane allows a "fire-and-forget" vote and has a simple smart contract interface that can easily be managed on already existing and trusted infrastructures such as Etherscan.

## Bi-voting

The issue is that switching the head when we disagree is risky. It's like relationships, you don't know if the next person will be better. Also, a "censure motion" may fail if there is not enough coordination towards a new head.

In fact, we need a way to signal the head that we disagree, by limiting its power.
On the other hand, we can also signal that we agree, by increasing its power. 

When combined with an Allocation Token, this governance enables bi-voting:
- "arbitrage" vote: buy/sell the token in order to do arbitrage on the token allocation
- "consensus" vote: vote with the token in order to select the governance head

The arbitrage vote is:
- faster: the head will be affected instantly because its treasury and room for maneuver will decrease
- more precise: you can buy/sell exactly the amount of tokens you want to
- simpler: you do not need to choose a new delegate, it's just a "yes" or "no" choice
- safer: there is no risk of replacing the head with someone worse
- more atomic: you can arbitrage the exact proposal you disagree with

Those two voting schemes are deeply tied because:
- when you sell the token, you decrease your voting power
- when you buy the token, you increase your voting power

--- START MATHS ---

We can detail the implications of each action (buy, sell, vote) on a Game theory matrix.

Let's suppose `X` and `X'` are your current and next power (positive if you vote for the current head, negative if you vote for any competitor).

We can make a list of all possible actions:
- A) Sell `x` tokens and decrease your absolute voting power (`|X'| = |X| - x`)
- B) Buy `x` tokens and increase your absolute voting power (`|X'| = |X| + x`)

- C) Switch your vote from the current head to a competitor and make the head lose `2X` votes to the competitor
- D) Switch your vote from a competitor to the current head and make the head win `2X` votes from the competitor
  
- A + C) Make the head lose `2X + x` votes and the competitor win `2X - x` votes
- A + D) Make the head win `2X - x` votes and the competitor lose `2X + x` votes
  
- B + C) Make the head lose `2X - x` votes and the competitor win `2X + x` votes
- B + D) Make the head win `2X + x` votes and the competitor lose `2X - x` votes

--- END MATHS ---

So you can only make your vote matter (signal "good head" or "bad head") if you buy the token (signal "good allocation"). When you sell the token (signal "bad allocation"), your absolute voting power decreases, and you are then in a risky position of uncertainty towards the vote finality (you essentially uncoordinate). 

Of course, things get more complex when you consider that the competitor can delegate his vote to the head.

This means when you disagree with something, you have to make a choice whether you want to signal "bad allocation" or "bad head". So the consensus vote is to be used as a last resort, when there is no way to signal "bad allocation", such that when the head is compromised or inactive.

Then, from a Game theory perspective, the strategy and Schelling points are clear and obvious for anyone
- do some arbitrage vote when the head is doing something you slightly disagree with (e.g. it allocated too much)
- do some consensus vote when the head is compromised (e.g. rugpull) or inactive (e.g. lost private key)

## FAQ

### How do the timelocked proposals work?

The head can `propose(...)` a proposal that will be public.

Once the delay has passed, if the head is still the head, it can `execute()` it.

Basically it does this pseudo-code:

```solidity
Proposal public proposal;

function propose(Call call) public onlyHead {
  /**
   * Set the proposal (replace if one was pending)
   */
  proposal = ...;
}

function execute() public onlyHead {
  /**
   * Check if there is a pending proposal
   */
  require(proposal != null);

  /**
   * Check if the delay has passed
   */
  require(block.timestamp > (proposal.timestamp + delay));

  /**
   * Execute the proposal
   */
  ...

  /**
   * Reset the proposal
   */
  proposal = null;
}
```

So there can be only one pending proposal.

### What if the head does bad stuff?

Operations done by the head are timelocked, so there is a safe delay for token holders to signal bad behaviour.

As explained above, when combined with an Allocation Token, you have two ways of signalling a bad behaviour:
- if the head is still legitimate (you just slightly disagree), you can do an arbitrage vote by buying/selling the token
- if the head is no longer legitimate (it's compromised or inactive), you can do a consensus vote to replace the head

If any of the operations aboves are doomed to fail (e.g. 51% attack, see below), there is a safe delay for token holders to sell the token before any rugpull.

### What if a whale acquires the majority of tokens and votes for itself?

This is a 51% attack. Still, since operations done by the head are timelocked, there is a safe delay to sell the token before any rugpull.

### Can I delegate my vote? 

Yes, when you vote for someone, you delegate your voting power, the head is the delegate that has the more voting power.

### Can the delay be changed?

The recommended delay is 2 weeks, leaving enough time to (re)coordinate in case the delegation chain is compromised.

This delay can be changed by the head (timelocked by the previous delay). For example it can be initially set to multiple months when setting up the DAO, in order to ensure no whale acquires large portions of tokens and to calm people against rugpulls. Since this action is timelocked, it will be reset each time the head changes, this ensures stability and consensus of the head (e.g. the head has been stable for 3 months, we can then safely set the delay to 2 weeks to start doing transactions). 

Note that a head setting a delay too low can effectively increase its room for maneuver, but at the risk of increasing the room for maneuver of an eventual attacker (either acquiring votes or just stealing the private key of the head). Any delay below 1 week should be considered highly dangerous and should trigger a recoordination to eject the head.

### What if some portion of token holders have lost their private key and still vote?

This a good side-effect because it adds a Lindy effect to the delegation, such that the more time your delegate was legitimate in the past, the more your delegate is legitimate in the present.

e.g. If your delegate hasn't been compromised in the last 5 years, you can expect it not to be compromised in the next 5 years.

e.g. If your delegate has done good job in the past in the last 5 years, you can expect it not to do stupid things in the next 5 years.

If the portion becomes problematic, there can be a proposal to change the governance contract, and thus reset the voting token balances.

### So there are two tokens?

Yes, for security reasons, the governance has its own token, which is a 1:1 proxy of the original token. Since it has more code tied to it, it can be slightly less secure, so it behaves just like a "layer-2" of the original token.

In fact, people SHOULD own a huge majority of voting token, so that their vote is more powerful, but if the governance contract has to be changed, they can safely unwrap their voting tokens into original tokens.

Liquidity pools and similar contracts SHOULD use the original token, this has the side-effect that the voting token supply is a good estimate of the amount of tokens holded by actual people.

### So people can't propose transactions?

There can be off-chain proposals and voting mechanisms, but only the head can propose on-chain transactions.

## Improvements?

### Majority proof

We could probably use (ZK?) proofs to prove that you're the ultimate delegate instead of recomputing it on-chain each time. But this is out of scope of this RFC. If this is done, we can probably throw away the need for two tokens, as the voting token would be a raw standard ERC20 just like the original token.
