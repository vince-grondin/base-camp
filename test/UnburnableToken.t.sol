// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/UnburnableToken.sol";

/**
 * @title Verifies the behavior of the `UnburnableToken` contract.
 * @author Roch
 */
contract UnburnableTokenTest is Test {
    using AddressGenerator for uint;

    uint32 immutable MAX_CLAIMABLE = 1000;
    uint32 immutable MAX_SUPPLY = 10000;

    UnburnableToken private unburnableToken;

    address private zeroAddress = address(0);
    address private userA = address(1);
    address private userB = address(2);
    address private userC = address(3);

    event TokensClaimedEvent(
        address recipient,
        uint amount,
        uint balance,
        uint totalSupply,
        uint totalClaimed
    );

    function setUp() public {
        unburnableToken = new UnburnableToken(MAX_SUPPLY);
    }

    /**
     * @dev Verifies that calling `claim` once all tokens were claimed reverts with a `AllTokensClaimed` error.
     * @param _address The address of the user claiming the tokens after they were all already claimed.
     */
    function test_GivenTotalSupplyDistributed_WhenClaiming_ThenAllTokensClaimedRevert(
        uint _address
    ) public {
        vm.assume(_address > 10000);
        uint claimIterations = MAX_SUPPLY / MAX_CLAIMABLE;
        claimAmountForDistinctUsers(claimIterations);

        vm.startPrank(_address.toAddress());
        expectAllTokensClaimedRevert();
        unburnableToken.claim();

        assertEq(unburnableToken.totalSupply(), 0);
        assertEq(unburnableToken.totalClaimed(), MAX_SUPPLY);

        for (uint i = 1; i <= claimIterations; i++) {
            assertEq(unburnableToken.balances(i.toAddress()), MAX_CLAIMABLE);
        }

        assertEq(unburnableToken.balances(_address.toAddress()), 0);
    }

    /**
     * @dev Verifies that calling `claim` reverts with a `TokensClaimed` when the sender has already claimed one or more
     *      tokens.
     */
    function test_GivenTokensAlreadyClaimedBySender_WhenClaiming_ThenTokensClaimedRevert()
        public
    {
        vm.startPrank(userA);
        unburnableToken.claim();

        expectTokensClaimedRevert();

        unburnableToken.claim();

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY - MAX_CLAIMABLE);
        assertEq(unburnableToken.totalClaimed(), MAX_CLAIMABLE);
        assertEq(unburnableToken.balances(userA), MAX_CLAIMABLE);
    }

    /**
     * @dev Verifies that calling `claim` when there's enough supply left and no tokens were previously claimed by the
     *      sender succeeds.
     * @param _address The address of the user claiming the tokens after they were all already claimed.
     */
    function test_GivenEnoughSupplyLeft_AndNoTokensClaimedBySender_WhenClaiming_ThenSuccess(
        uint _address
    ) public {
        vm.assume(_address > 10000);

        uint claimIterations = (MAX_SUPPLY / MAX_CLAIMABLE) - 1;
        claimAmountForDistinctUsers(claimIterations);

        vm.startPrank(_address.toAddress());
        unburnableToken.claim();

        uint expectedTotalClaimedAmount = (MAX_CLAIMABLE * claimIterations) +
            MAX_CLAIMABLE;
        assertEq(
            unburnableToken.totalSupply(),
            MAX_SUPPLY - expectedTotalClaimedAmount
        );
        assertEq(unburnableToken.totalClaimed(), expectedTotalClaimedAmount);

        for (uint i = 1; i <= claimIterations; i++) {
            assertEq(unburnableToken.balances(i.toAddress()), MAX_CLAIMABLE);
        }

        assertEq(unburnableToken.balances(_address.toAddress()), MAX_CLAIMABLE);
    }

    /**
     * @dev Verifies that calling `safeTransfer` with a `_to` zero address reverts with an `UnsafeTransfer` error.
     * @param _amount The amount to transfer.
     */
    function test_GivenToAddressIsZeroAddress_WhenSafeTransfer_ThenUnsafeTransferRevert(
        uint _amount
    ) public {
        vm.assume(_amount > 0 && _amount <= MAX_CLAIMABLE);

        expectUnsafeTransferRevert(zeroAddress);

        unburnableToken.safeTransfer(zeroAddress, _amount);

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY);
        assertEq(unburnableToken.totalClaimed(), 0);
        assertEq(unburnableToken.balances(userA), 0);
        assertEq(unburnableToken.balances(zeroAddress), 0);
    }

    /**
     * @dev Verifies that calling `safeTransfer` with a `_to` recipient that has a 0 balance reverts with an
     *      `UnsafeTransfer` error.
     * @param _amount The amount to transfer.
     * @param _to The address of the sender.
     */
    function test_GivenRecipientNotFunded_WhenSafeTransfer_ThenUnsafeTransferRevert(
        uint _amount,
        address _to
    ) public {
        vm.assume(_amount > 0 && _amount <= MAX_CLAIMABLE);
        vm.assume(_to != zeroAddress && _to != userA);

        vm.deal(_to, 0 ether);

        vm.startPrank(userA);
        expectUnsafeTransferRevert(_to);
        unburnableToken.safeTransfer(_to, _amount);

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY);
        assertEq(unburnableToken.totalClaimed(), 0);
        assertEq(unburnableToken.balances(userA), 0);
        assertEq(unburnableToken.balances(zeroAddress), 0);
    }

    /**
     * @dev Verifies that calling `safeTransfer` to transfer an amount greater than the sender's balance reverts with a
     *      `InsufficientSenderSupply` error.
     * @param _sender The address of the sender.
     * @param _to The address to transfer the amount to.
     * @param _transferAmount The amount to transfer from the sender to the `_to` recipient.
     */
    function test_GivenAmountGreaterThanSenderBalance_WhenSafeTransfer_ThenInsufficientSenderSupplyRevert(
        address _sender,
        address _to,
        uint _transferAmount
    ) public {
        uint _senderBalance = MAX_CLAIMABLE;
        vm.assume(_sender != zeroAddress);
        vm.assume(_to != _sender);
        vm.assume(_transferAmount > _senderBalance);

        vm.deal(_to, 1 ether);

        vm.startPrank(_sender);
        unburnableToken.claim();

        expectInsufficientSenderSupplyRevert(_senderBalance);

        unburnableToken.safeTransfer(_to, _transferAmount);

        uint expectedClaimed = MAX_CLAIMABLE;
        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY - expectedClaimed);
        assertEq(unburnableToken.totalClaimed(), expectedClaimed);
        assertEq(unburnableToken.balances(_sender), _senderBalance);
        assertEq(unburnableToken.balances(_to), 0);
    }

    /**
     * @dev Verifies that calling `safeTransfer` to transfer an amount lower or equal to the sender's balance succeeds.
     * @param _sender The address of the sender.
     * @param _to The address to transfer the amount to.
     * @param _transferAmount The amount to transfer from the sender to the `_to` recipient.
     */
    function test_GivenNonZeroAddress_AndAmountLowerOrEqualSenderBalance_WehnSafeTransfer_ThenSuccess(
        address _sender,
        address _to,
        uint _transferAmount
    ) public {
        uint _senderBalance = MAX_CLAIMABLE;
        vm.assume(_sender != zeroAddress);
        vm.assume(_to != zeroAddress);
        vm.assume(_transferAmount > 0 && _transferAmount <= _senderBalance);

        vm.deal(_to, 1 ether);

        vm.startPrank(_sender);
        unburnableToken.claim();

        unburnableToken.safeTransfer(_to, _transferAmount);

        uint expectedClaimed = MAX_CLAIMABLE;
        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY - expectedClaimed);
        assertEq(unburnableToken.totalClaimed(), expectedClaimed);
        assertEq(
            unburnableToken.balances(_sender),
            _senderBalance - _transferAmount
        );
        assertEq(unburnableToken.balances(_to), _transferAmount);
    }

    /**
     * @dev Helper function to claim for `_iterations` distinct addresses.
     * @param iterations The number of generated address to attribute the `_amount` to.
     */
    function claimAmountForDistinctUsers(uint iterations) private {
        for (uint i = 1; i <= iterations; i++) {
            vm.startPrank(i.toAddress());
            unburnableToken.claim();
            vm.stopPrank();
        }
    }

    /**
     * @dev Helper function to verify that an `AllTokensClaimed` revert occurs.
     */
    function expectAllTokensClaimedRevert() private {
        vm.expectRevert(
            abi.encodeWithSelector(UnburnableToken.AllTokensClaimed.selector)
        );
    }

    /**
     * @dev Helper function to verify that an `ExceedsUserMaxClaimable` revert occurs.
     */
    function expectExceedsUserMaxClaimableRevert() private {
        vm.expectRevert(
            abi.encodeWithSelector(
                UnburnableToken.ExceedsUserMaxClaimable.selector,
                MAX_CLAIMABLE
            )
        );
    }

    /**
     * @dev Helper function to verify that an `InsufficientSupply` revert occurs.
     */
    function expectInsufficientSupplyRevert(uint remainingSupply) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                UnburnableToken.InsufficientSupply.selector,
                remainingSupply
            )
        );
    }

    /**
     * @dev Helper function to verify that an `InsufficientSenderSupply` revert occurs.
     */
    function expectInsufficientSenderSupplyRevert(uint _balance) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                UnburnableToken.InsufficientSenderSupply.selector,
                _balance
            )
        );
    }

    /**
     * @dev Helper function to verify that a `TokensClaimed` revert occurs.
     */
    function expectTokensClaimedRevert() private {
        vm.expectRevert(
            abi.encodeWithSelector(UnburnableToken.TokensClaimed.selector)
        );
    }

    /**
     * @dev Helper function to verify that an `UnsafeTransfer` revert occurs.
     */
    function expectUnsafeTransferRevert(address _address) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                UnburnableToken.UnsafeTransfer.selector,
                _address
            )
        );
    }
}

library AddressGenerator {
    function toAddress(uint _address) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(_address)))));
    }
}
