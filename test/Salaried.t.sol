// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Inheritance.sol";

/// @dev Verifies the behavior of the `Salaried` contract
contract SalariedTest is Test {
    Salaried private salariedEmployee;

    function setUp() public {
        salariedEmployee = new Salaried(1, 2, 100000);
    }

    /// @dev Verifies that a Salaried employee's annual cost matches their annual salary.
    function test_GivenSalariedInstantiated_WhenGettingAnnualCost_ThenAnnualSalaryReturned()
        public
    {
        uint256 result = salariedEmployee.getAnnualCost();

        assertEq(100000, result);
    }
}
