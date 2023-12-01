// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Inheritance.sol";

/// @dev Verifies the behavior of the `Manager` contract
contract ManagerTest is Test {
    Manager private manager;

    function setUp() public {
        manager = new Manager();
    }

    /// @dev Verifies that adding a report does not fail
    function test_GivenNoExistingReports_WhenAddingReport_ThenNoFailure(
        uint256 report1,
        uint256 report2
    ) public {
        manager.addReport(report1);
        manager.addReport(report2);
    }

    /// @dev Verifies that reseting reports does not fail
    function test_GivenExistingReports_WhenResetingReports_ThenNoFailure(
        uint256 report1,
        uint256 report2
    ) public {
        manager.addReport(report1);
        manager.addReport(report2);
        manager.resetReports();
    }
}
