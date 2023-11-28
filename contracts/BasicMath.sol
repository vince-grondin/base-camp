// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract BasicMath {
     /// @notice Subtracts a number from another.
     /// @dev If _a - _b does not underflow, it should return the difference and an error of false.
     ///      If _a - _b underflows, it should return 0 as the difference, and an error of true.
     /// @param _a Number to subtract from
     /// @param _b Number to subtract
     /// @return difference The result of the subtraction
    /// @return error Whether sum resulted in an under and `sum` was consequently returned with a value of 0
    function subtractor(uint _a, uint _b) external pure returns (uint difference, bool error) {
        unchecked {
            uint result = _a - _b;
            if (result > _a) return (0, true);
            return (result, result > _a);
        }
    }

    /// @notice Adds two numbers.
    /// @dev If _a + _b do not overflow, it should return the sum and an error of false.
    ///      If _a + _b overflow, it should return 0 as the sum, and an error of true.
    /// @param _a A number
    /// @param _b A number to add to `_a`
    /// @return sum The result of the sum
    /// @return error Whether sum resulted in an overflow and `sum` was consequently returned with a value of 0
    function adder(uint _a, uint _b) external pure returns (uint sum, bool error) {
        unchecked {
            uint result = _a + _b;
            if (result < _a) return (0, true);
            return (result, false);
        }
    }
}
