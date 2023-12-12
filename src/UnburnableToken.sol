// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title Solution for the [Minimal Tokens Exercise](https://docs.base.org/base-camp/docs/minimal-tokens/minimal-tokens-exercise).
 * @author Roch
 */
contract UnburnableToken {
    mapping(address => uint) public balances;

    uint16 immutable MAX_CLAIMABLE = 1000;

    uint32 immutable MAX_SUPPLY = 100000000;

    uint public totalSupply;

    uint public totalClaimed;

    error AllTokensClaimed();

    error LowTransferAmount(uint amount);

    error InsufficientSupply(uint remainingSupply);

    error ExceedsUserMaxClaimable(uint maxClaimable);

    error InsufficientSenderSupply(uint balance);

    error UnsafeTransfer(address sender);

    error TokensClaimed();

    event TokensClaimedEvent(
        address recipient,
        uint amount,
        uint balance,
        uint totalSupply,
        uint totalClaimed
    );

    constructor(uint32 _totalSupply) {
        totalSupply = _totalSupply > 0 ? _totalSupply : MAX_SUPPLY;
    }

    /**
     * @notice Adds the maximum claimable amount per user to the sender's balance.
     * @dev Reverts with a `TokensClaimed` error if a sender tries to claim more than once.
     *      Reverts with a `AllTokensClaimed` error if there are no tokens left to claim.
     *      Reverts with a `InsufficientSupply` error if there are not enough tokens left to claim.
     */
    function claim() public {
        if (balances[msg.sender] != 0)
            revert TokensClaimed();

        if (totalSupply == 0)
            revert AllTokensClaimed();

        balances[msg.sender] = MAX_CLAIMABLE;
        totalSupply -= MAX_CLAIMABLE;
        totalClaimed += MAX_CLAIMABLE;

        emit TokensClaimedEvent(
            msg.sender,
            MAX_CLAIMABLE,
            balances[msg.sender],
            totalSupply,
            totalClaimed
        );
    }

    /**
     * @notice Transfer the `_amount` from the sender to the `_to` address.
     * @param _to The address where to transfer the `_amount` amount.
     * @param _amount The amount to transfer.
     */
    function safeTransfer(address _to, uint _amount) public {
        if (_to == 0x0000000000000000000000000000000000000000 || _to.balance == 0)
            revert UnsafeTransfer(_to);

        if (balances[msg.sender] < _amount)
            revert InsufficientSenderSupply(balances[msg.sender]);

        balances[_to] += _amount;
        balances[msg.sender] -= _amount;
    }
}
