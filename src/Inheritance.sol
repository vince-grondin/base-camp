// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Base contract for managing an employee.
/// @author Roch
/// @notice Base contract for managing an employee.
abstract contract Employee {
    uint256 public idNumber;
    uint256 public managerId;

    /// @notice Instantiates an `Employee` contract.
    /// @param _idNumber The employee ID.
    /// @param _managerId The manager ID.
    constructor(uint256 _idNumber, uint256 _managerId) {
        idNumber = _idNumber;
        managerId = _managerId;
    }

    /// @notice Gets the annual cost for this employee.
    /// @return The annual cost for this employee.
    function getAnnualCost() public virtual returns (uint256);
}

/// @title Contract to manage a `Salaried` employee.
/// @author Roch
/// @notice Contract to manage a `Salaried` employee.
contract Salaried is Employee {
    uint256 public annualSalary;

    /// @notice Instantiates a `Salaried` contract.
    /// @param _idNumber The employee ID.
    /// @param _managerId The manager ID.
    /// @param _annualSalary The annual salary.
    constructor(
        uint256 _idNumber,
        uint256 _managerId,
        uint256 _annualSalary
    ) Employee(_idNumber, _managerId) {
        annualSalary = _annualSalary;
    }

    /// @dev Annual cost for `Salaried` is their annual salary.
    /// @inheritdoc Employee
    function getAnnualCost() public view override returns (uint256) {
        return annualSalary;
    }
}

/// @title Contract to manage a `Hourly` employee.
/// @author Roch
/// @notice Contract to manage a `Hourly` employee.
contract Hourly is Employee {
    uint16 private constant ANNUAL_HOURS = 2080;
    uint256 public hourlyRate;

    /// @notice Instantiates a `Hourly` contract.
    /// @param _idNumber The employee ID.
    /// @param _managerId The manager ID.
    /// @param _hourlyRate The hourly rate.
    constructor(
        uint256 _idNumber,
        uint256 _managerId,
        uint256 _hourlyRate
    ) Employee(_idNumber, _managerId) {
        hourlyRate = _hourlyRate;
    }

    /// @dev Annual cost for `Hourly` is their hourly salary spread over a year.
    /// @inheritdoc Employee
    function getAnnualCost() public view override returns (uint256) {
        return hourlyRate * ANNUAL_HOURS;
    }
}

/// @title Contract with `Manager` data and behavior.
/// @author Roch
/// @notice Contract with `Manager` data and behavior.
contract Manager {
    uint256[] public employeeIDs;

    event ReportAdded(uint256 report);
    event ReportsReset();

    /// @notice Adds a report to this manager.
    /// @param _report The report to add to this manager.
    function addReport(uint256 _report) public {
        employeeIDs.push(_report);
        emit ReportAdded(_report);
    }

    /// @notice Resets the reports of this manager.
    function resetReports() public {
        delete employeeIDs;
        emit ReportsReset();
    }
}

/// @title Contract with `Salesperson` data and behavior.
/// @author Roch
/// @notice Contract with `Salesperson` data and behavior.
contract Salesperson is Hourly {

    /// @notice Instantiates a `Salesperson` contract.
    /// @param _idNumber The employee ID.
    /// @param _managerId The manager ID.
    /// @param _hourlyRate The hourly rate.
    constructor(
        uint256 _idNumber,
        uint256 _managerId,
        uint256 _hourlyRate
    ) Hourly(_idNumber, _managerId, _hourlyRate) {}
}

/// @title Contract with `EngineeringManager` data and behavior.
/// @author Roch
/// @notice Contract with `EngineeringManager` data and behavior.
contract EngineeringManager is Salaried, Manager {

    /// @notice Instantiates an `EngineeringManager` contract.
    /// @param _idNumber The employee ID.
    /// @param _managerId The manager ID.
    /// @param _annualSalary The annual salary.
    constructor(
        uint256 _idNumber,
        uint256 _managerId,
        uint256 _annualSalary
    ) Salaried(_idNumber, _managerId, _annualSalary) {}
}

/// @title Contract referencing the `Salesperson` and `EngineeringManager` deployed contracts.
/// @author Roch
/// @notice Contract referencing the `Salesperson` and `EngineeringManager` deployed contracts.
contract InheritanceSubmission {
    address public salesPerson;
    address public engineeringManager;

    /// @notice Instantiates an `InheritanceSubmission` contract.
    /// @param _salesPerson The deployed `Salesperson` contract address.
    /// @param _engineeringManager The deployed `EngineeringManager` contract address.
    constructor(address _salesPerson, address _engineeringManager) {
        salesPerson = _salesPerson;
        engineeringManager = _engineeringManager;
    }
}
