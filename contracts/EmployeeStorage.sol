// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Manages an employee's shares and salary
/// @author Roch
/// @notice Manages an employee's shares and salary
contract EmployeeStorage {
    uint16 private shares;
    uint24 private salary;
    uint256 public idNumber;
    string public name;

    error TooManyShares(uint16 shares);

    constructor(
        uint16 _shares,
        string memory _name,
        uint24 _salary,
        uint256 _idNumber
    ) {
        shares = _shares;
        name = _name;
        salary = _salary;
        idNumber = _idNumber;
    }

    /// @notice Returns the employee's salary.
    /// @return The employee's salary
    function viewSalary() external view returns (uint24) {
        return salary;
    }

    /// @notice Returns the number of shares held by the employee.
    /// @return The number of shares held by the employee
    function viewShares() external view returns (uint32) {
        return shares;
    }

    /// @notice Adds [_newShares] number of shares to the number of shares allocated to the employee.
    /// @param _newShares The additional number of shares to allocate to the employee
    function grantShares(uint16 _newShares) external {
        if (_newShares > 5000) {
            revert("Too many shares");
        }

        uint16 updatedShares = shares + _newShares;

        if (updatedShares > 5000) {
            revert TooManyShares(updatedShares);
        }

        shares = updatedShares;
    }

    /// @notice Validates the structure of this contract. Only needed for exercise verification.
    /// @dev Needed for exercise verification.
    /// @param _slot Slot
    /// @return r
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload (_slot)
        }
    }

    /// @notice Sets the number of shares to 1000.
    /// @dev Needed for exercise verification.
    function debugResetShares() public {
        shares = 1000;
    }
}
