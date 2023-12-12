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
     * @dev Verifies that calling `claim` with an amount greater than the remaining supply reverts with an
     *      `InsufficientSupply` error.
     * @param _address1 An address greater than 200000.
     * @param _address2 Another address greater than 200000.
     */
    function test_GivenClaimedAmountGreaterThanRemainingSupply_WhenClaiming_ThenInsufficientSupplyRevert(
        uint _address1,
        uint _address2
    ) public {
        vm.assume(_address1 > 10000);
        vm.assume(_address2 > 10000);
        vm.assume(_address1 != _address2);

        uint iterationAmount = 500;
        uint claimIterations = (MAX_SUPPLY / 500) - 1;
        claimAmountForDistinctUsers(iterationAmount, claimIterations);

        vm.startPrank(_address1.toAddress());
        unburnableToken.claim(300);
        vm.stopPrank();

        vm.startPrank(_address2.toAddress());
        expectInsufficientSupplyRevert(200);
        unburnableToken.claim(201);

        assertEq(unburnableToken.totalSupply(), 200);
        assertEq(unburnableToken.totalClaimed(), MAX_SUPPLY - 200);

        for (uint i = 1; i <= claimIterations; i++) {
            assertEq(unburnableToken.balances(i.toAddress()), iterationAmount);
        }

        assertEq(unburnableToken.balances(_address2.toAddress()), 0);
    }

    /**
     * @dev Verifies that calling `claim` once all tokens were claimed reverts with a `AllTokensClaimed` error.
     * @param _amount1 The amount to claimed after all tokens were claimed.
     * @param _address The address of the user claiming the tokens after they were all already claimed.
     */
    function test_GivenTotalSupplyDistributed_WhenClaiming_ThenAllTokensClaimedRevert(
        uint _amount1,
        uint _address
    ) public {
        vm.assume(_address > 10000);
        uint iterationAmount = 500;
        uint claimIterations = MAX_SUPPLY / 500;
        claimAmountForDistinctUsers(iterationAmount, claimIterations);

        vm.startPrank(_address.toAddress());
        expectAllTokensClaimedRevert();
        unburnableToken.claim(_amount1);

        assertEq(unburnableToken.totalSupply(), 0);
        assertEq(unburnableToken.totalClaimed(), MAX_SUPPLY);

        for (uint i = 1; i <= claimIterations; i++) {
            assertEq(unburnableToken.balances(i.toAddress()), iterationAmount);
        }

        assertEq(unburnableToken.balances(_address.toAddress()), 0);
    }

    /**
     * @dev Verifies that calling `claim` reverts with an `ExceedsUserMaxClaimable` error when the sender claims more
     *      than the maximum amount allowed to be claimed by a user.
     * @param _amount The amount to claim by the user, greater than the maximum claimable amount.
     */
    function test_GivenAmountGreaterThanOneThousand_WhenClaiming_ThenTokensClaimedRevert(
        uint _amount
    ) public {
        vm.assume(_amount > MAX_CLAIMABLE && _amount < MAX_SUPPLY);

        vm.startPrank(userA);
        expectExceedsUserMaxClaimableRevert();
        unburnableToken.claim(_amount);

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY);
        assertEq(unburnableToken.totalClaimed(), 0);
        assertEq(unburnableToken.balances(userA), 0);
    }

    /**
     * @dev Verifies that calling `claim` reverts with a `TokensClaimed` when the sender has already claimed one or more
     *      tokens.
     * @param _amount The amount claimed by the user.
     */
    function test_GivenTokensAlreadyClaimedBySender_WhenClaiming_ThenTokensClaimedRevert(
        uint _amount
    ) public {
        vm.assume(_amount > 0 && _amount < MAX_CLAIMABLE);

        vm.startPrank(userA);
        unburnableToken.claim(_amount);

        expectTokensClaimedRevert(_amount);

        unburnableToken.claim(1);

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY - _amount);
        assertEq(unburnableToken.totalClaimed(), _amount);
        assertEq(unburnableToken.balances(userA), _amount);
    }

    /**
     * @dev Verifies that calling `claim` when there's enough supply left and no tokens were previously claimed by the
     *      sender succeeds.
     * @param _amount The amount claimed by a user.
     * @param _address The address of the user claiming the tokens after they were all already claimed.
     */
    function test_GivenEnoughSupplyLeft_AndNoTokensClaimedBySender_WhenClaiming_ThenSuccess(
        uint _amount,
        uint _address
    ) public {
        uint iterationAmount = 500;
        vm.assume(_amount > 0 && _amount < iterationAmount);
        vm.assume(_address > 10000);

        uint claimIterations = (MAX_SUPPLY / 500) - 1;
        claimAmountForDistinctUsers(iterationAmount, claimIterations);

        vm.startPrank(_address.toAddress());
        unburnableToken.claim(_amount);

        uint expectedTotalClaimedAmount = (iterationAmount * claimIterations) +
            _amount;
        assertEq(
            unburnableToken.totalSupply(),
            MAX_SUPPLY - expectedTotalClaimedAmount
        );
        assertEq(unburnableToken.totalClaimed(), expectedTotalClaimedAmount);

        for (uint i = 1; i <= claimIterations; i++) {
            assertEq(unburnableToken.balances(i.toAddress()), iterationAmount);
        }

        assertEq(unburnableToken.balances(_address.toAddress()), _amount);
    }

    /**
     * @dev Verifies that calling `safeTransfer` with a `_to` zero address reverts with an `UnsafeTransfer` error.
     * @param _amount The amount to transfer.
     */
    function test_GivenToAddressIsZeroAddress_WhenSafeTransfer_ThenUnsafeTransferRevert(
        uint _amount
    ) public {
        vm.assume(_amount > 0);

        expectUnsafeTransferRevert(zeroAddress);

        unburnableToken.safeTransfer(zeroAddress, _amount);

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY);
        assertEq(unburnableToken.totalClaimed(), 0);
        assertEq(unburnableToken.balances(userA), 0);
        assertEq(unburnableToken.balances(zeroAddress), 0);
    }

    /**
     * @dev Verifies that calling `safeTransfer` with a `_amount` zero reverts with an `UnsafeTransfer` error.
     * @param _address The address of the sender.
     */
    function test_GivenAmountIsZero_WhenSafeTransfer_ThenUnsafeTransferRevert(
        address _address
    ) public {
        vm.assume(_address != zeroAddress);
        uint amount = 0;

        vm.startPrank(userA);
        expectUnsafeTransferRevert(_address);
        unburnableToken.safeTransfer(_address, amount);

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
     * @param _senderBalance The balance of the sender.
     * @param _transferAmount The amount to transfer from the sender to the `_to` recipient.
     */
    function test_GivenAmountGreaterThanSenderBalance_WhenSafeTransfer_ThenInsufficientSenderSupplyRevert(
        address _sender,
        address _to,
        uint _senderBalance,
        uint _transferAmount
    ) public {
        vm.assume(_sender != zeroAddress);
        vm.assume(_to != zeroAddress);
        vm.assume(_senderBalance > 0 && _senderBalance <= MAX_CLAIMABLE);
        vm.assume(_transferAmount > _senderBalance);

        vm.startPrank(_sender);
        unburnableToken.claim(_senderBalance);

        expectInsufficientSenderSupplyRevert(_senderBalance);

        unburnableToken.safeTransfer(_to, _transferAmount);

        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY - _senderBalance);
        assertEq(unburnableToken.totalClaimed(), _senderBalance);
        assertEq(unburnableToken.balances(_sender), _senderBalance);
        assertEq(unburnableToken.balances(_to), 0);
    }

    function test_GivenNonZeroAddress_AndAmountLowerOrEqualSenderBalance_WehnSafeTransfer_ThenSuccess(
        address _sender,
        address _to,
        uint _senderBalance,
        uint _transferAmount
    ) public {
        vm.assume(_sender != zeroAddress);
        vm.assume(_to != zeroAddress);
        vm.assume(_senderBalance > 0 && _senderBalance <= MAX_CLAIMABLE);
        vm.assume(_transferAmount > 0 && _transferAmount <= _senderBalance);

        vm.startPrank(_sender);
        unburnableToken.claim(_senderBalance);

        bool result = unburnableToken.safeTransfer(_to, _transferAmount);

        assertTrue(result);
        assertEq(unburnableToken.totalSupply(), MAX_SUPPLY - _senderBalance);
        assertEq(unburnableToken.totalClaimed(), _senderBalance);
        assertEq(
            unburnableToken.balances(_sender),
            _senderBalance - _transferAmount
        );
        assertEq(unburnableToken.balances(_to), _transferAmount);
    }

    /**
     * @dev Helper function to claim `_amount` for `_iterations` distinct addresses.
     * @param _amount The amount to claim for each generated address.
     * @param iterations The number of generated address to attribute the `_amount` to.
     */
    function claimAmountForDistinctUsers(
        uint _amount,
        uint iterations
    ) private {
        for (uint i = 1; i <= iterations; i++) {
            vm.startPrank(i.toAddress());
            unburnableToken.claim(_amount);
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
    function expectTokensClaimedRevert(uint claimed) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                UnburnableToken.TokensClaimed.selector,
                claimed
            )
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
