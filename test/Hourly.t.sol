// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Inheritance.sol";

/// @dev Verifies the behavior of the `Hourly` contract
contract HourlyTest is Test {
    Hourly private hourlyEmployee;

    function setUp() public {
        hourlyEmployee = new Hourly(1, 2, 60);
    }

    /// @dev Verifies that a Hourly employee's annual cost matches their hourly salary spread over a year.
    function test_GivenHourlyInstantiated_WhenGettingAnnualCost_ThenHourlySalaryOverYearReturned()
        public
    {
        uint256 result = hourlyEmployee.getAnnualCost();

        assertEq(124800, result);
    }
}