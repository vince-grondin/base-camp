// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ErrorTriageExercise.sol";

/**
 * @title Verifies the behavior of the `ErrorTriageExercise` contract.
 * @author Roch
 */
contract ErrorTriageExerciseTest is Test {
    ErrorTriageExercise errorTriageExercise;

    uint256[5] fiveEntries = [uint256(10), 53, 1, 63, 1];

    function setUp() public {
        errorTriageExercise = new ErrorTriageExercise();
    }

    /**
     * @dev Verifies that when the difference between each argument and its neighbor is negative then the absolute
     *      values of the differences are returned.
     */
    function test_GivenNumbersWithNegativeDifference_WhenCallingDiffWithNeighbor_ThenAbsoluteValuesReturned()
        public
    {
        uint _a = 1;
        uint _b = 2;
        uint _c = 5;
        uint _d = 1;

        uint[] memory results = errorTriageExercise.diffWithNeighbor(
            _a,
            _b,
            _c,
            _d
        );

        assertEq(results[0], 1);
        assertEq(results[1], 3);
        assertEq(results[2], 4);
    }

    /**
     * @dev Verifies that when the difference between each argument and its neighbor is positive then the absolute
     *      values of the differences are returned.
     */
    function test_GivenNumbersWithPositiveDifference_WhenCallingDiffWithNeighbor_ThenAbsoluteValuesReturned()
        public
    {
        uint _a = 9;
        uint _b = 4;
        uint _c = 3;
        uint _d = 2;

        uint[] memory results = errorTriageExercise.diffWithNeighbor(
            _a,
            _b,
            _c,
            _d
        );

        assertEq(results[0], 5);
        assertEq(results[1], 1);
        assertEq(results[2], 1);
    }

    /**
     * @dev Verifies that `applyModifier` changes a value by the value of a negative modifier.
     */
    function test_GivenModifierIsNegative_WhenCallingApplyModifier_ThenModifiedValueReturned()
        public
    {
        uint _base = 2023;
        int _modifier = -100;

        uint result = errorTriageExercise.applyModifier(_base, _modifier);

        assertEq(result, 1923);
    }

    /**
     * @dev Verifies that `applyModifier` changes a value by the value of a positive modifier.
     */
    function test_GivenModifierIsPositive_WhenCallingApplyModifier_ThenModifiedValueReturned()
        public
    {
        uint _base = 2023;
        int _modifier = 100;

        uint result = errorTriageExercise.applyModifier(_base, _modifier);

        assertEq(result, 2123);
    }

    /**
     * @dev Verifies that `popWithReturn` returns 0 when no entries were added to the array.
     */
    function test_GivenNoEntriesWereAdded_WhenCallingPopWithReturn_ThenZeroReturned()
        public
    {
        uint result = errorTriageExercise.popWithReturn();

        assertEq(result, 0);
    }

    /**
     * @dev Verifies that `popWithReturn` returns latest entry and array still holds remaining items.
     */
    function test_GivenManyItemsInArray_WhenCallingPopWithReturnOnce_ThenLatestEntryReturned_AndArrayNotEmpty() public {
        addFiveEntries();

        uint256 result = errorTriageExercise.popWithReturn();

        assertEq(result, fiveEntries[4]);
        assertEq(errorTriageExercise.getArr().length, 4);
        assertEqArrayUpToIndex(errorTriageExercise.getArr(), fiveEntries, 3);
    }

    /**
     * @dev Verifies that calling `popWithReturn` multiple times returns latest entry and array still holds remaining
     *      items.
     */
    function test_GivenManyItemsInArray_WhenCallingPopWithReturnMultipleTimes_ThenLatestEntryReturned_AndArrayNotEmpty() public {
        addFiveEntries();

        errorTriageExercise.popWithReturn();
        errorTriageExercise.popWithReturn();
        uint256 result = errorTriageExercise.popWithReturn();

        assertEq(result, fiveEntries[2]);
        assertEq(errorTriageExercise.getArr().length, 2);
        assertEqArrayUpToIndex(errorTriageExercise.getArr(), fiveEntries, 1);
    }

    /**
     * @dev Helper function to add five entries to add to the `errorTriageExercise` contract's array.
     */
    function addFiveEntries() private {
        for (uint256 i = 0; i < fiveEntries.length; i++) {
            errorTriageExercise.addToArr(fiveEntries[i]);
        }
    }

    /**
     * @dev Asserts the entries in `_actual` matches the entries in `_expected` up to index `_upToIndex`.
     * @param _actual Array to assert
     * @param _expected Array to assert against
     * @param _upToIndex Index up to which to assert the values at the same index in `_actual` and `_expected` are
     *        equal
     */
    function assertEqArrayUpToIndex(
        uint256[] memory _actual,
        uint256[5] memory _expected,
        uint256 _upToIndex
    ) private {
        for (uint256 i = 0; i <= _upToIndex; i++) {
            assertEq(_actual[i], _expected[i]);
        }
    }
}
