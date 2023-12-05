// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Solution for the [Error Triage Exercise](https://docs.base.org/base-camp/docs/error-triage/error-triage-exercise).
 * @author Roch
 * @notice Solution for the [Error Triage Exercise](https://docs.base.org/base-camp/docs/error-triage/error-triage-exercise).
 */
contract ErrorTriageExercise {
    /**
     * @notice Finds the difference between each uint with it's neighbor (a to b, b to c, etc.)
     * @return The array with the absolute integer difference of each pairing.
     */
    function diffWithNeighbor(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint[] memory results = new uint[](3);

        results[0] = abs(int256(_a) - int256(_b));
        results[1] = abs(int256(_b) - int256(_c));
        results[2] = abs(int256(_c) - int256(_d));

        return results;
    }

    /**
     * @dev Returns the absolute value of `_number`.
     * @param _number A number
     * @return The absolute value of `_number`.
     */
    function abs(int256 _number) private pure returns (uint256) {
        return _number < 0 ? uint256(-_number) : uint256(_number);
    }

    /**
     * @notice Changes the _base by the value of _modifier. Base is always >= 1000. Modifiers can be between positive
     *         and negative 100.
     * @return The modified value.
     */
    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (uint) {
        int256 result = int256(_base) + _modifier;
        return result > 0 ? uint256(result) : 0;
    }

    uint[] arr;

    /**
     * @notice Pops the last element from the array.
     * @return The popped value (unlike the built-in function).
     */
    function popWithReturn() public returns (uint) {
        if (arr.length == 0) return 0;

        uint value = arr[arr.length - 1];
        arr.pop();

        return value;
    }

    // The utility functions below are working as expected
    function addToArr(uint _num) public {
        arr.push(_num);
    }

    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function resetArr() public {
        delete arr;
    }
}
