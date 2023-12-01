// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Inheritance.sol";

/// @dev Verifies the behavior of the `Salesperson` contract
contract SalespersonTest is Test {
    Salesperson private salesperson;

    function setUp() public {
        salesperson = new Salesperson(1, 2, 60);
    }

    /// @dev Verifies that a Salesperson employee's annual cost matches their hourly salary spread over a year.
    function test_GivenSalespersonInstantiated_WhenGettingAnnualCost_ThenHourlySalaryOverYearReturned()
        public
    {
        uint256 result = salesperson.getAnnualCost();

        assertEq(124800, result);
    }
}
