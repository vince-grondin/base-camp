// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Inheritance.sol";

/// @dev Verifies the behavior of the `EngineeringManager` contract
contract EngineeringManagerTest is Test {
    EngineeringManager private engineeringManager;

    function setUp() public {
        engineeringManager = new EngineeringManager(1, 2, 100000);
    }

    /// @dev Verifies that adding a report does not fail
    function test_GivenNoExistingReports_WhenAddingReport_ThenNoFailure(
        uint256 report1,
        uint256 report2
    ) public {
        engineeringManager.addReport(report1);
        engineeringManager.addReport(report2);
    }

    /// @dev Verifies that reseting reports does not fail
    function test_GivenExistingReports_WhenResetingReports_ThenNoFailure(
        uint256 report1,
        uint256 report2
    ) public {
        engineeringManager.addReport(report1);
        engineeringManager.addReport(report2);
        engineeringManager.resetReports();
    }

    /// @dev Verifies that an EngineeringManager's annual cost matches their annual salary.
    function test_GivenEngineeringManagerInstantiated_WhenGettingAnnualCost_ThenAnnualSalaryReturned()
        public
    {
        uint256 result = engineeringManager.getAnnualCost();

        assertEq(100000, result);
    }
}
