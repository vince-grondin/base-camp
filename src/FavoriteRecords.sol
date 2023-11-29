// SPDX-License-Identifier: MIT 
pragma solidity 0.8.17;

/// @title Manages favorite records for users of this contract
/// @author Roch
/// @notice Manages favorite records for users of this contract
contract FavoriteRecords {
    mapping (string => bool) public approvedRecords;
    string[] private approvedRecordNames;

    mapping (address => mapping (string => bool)) internal userFavorites;
    mapping (address => string[]) internal userFavoriteRecordsNames;

    error NotApproved(string recordName);

    constructor(string[] memory _approvedRecords) {
        initializeApprovedRecords(_approvedRecords);
    }

    /// @notice Loads an array of approved records.
    /// @dev Loads `_approvedRecords` into the `approvedRecords` mapping and the `approvedRecordNames` array.
    /// @param _approvedRecords The approved records to load.
    function initializeApprovedRecords(string[] memory _approvedRecords) private {
        for (uint256 index = 0; index < _approvedRecords.length; index++) {
            string memory record = _approvedRecords[index];
            approvedRecords[record] = true;
            approvedRecordNames.push(record);
        }
    }

    /// @notice Returns a list of all of the names currently indexed.
    /// @dev return a list of all of the names currently indexed in `approvedRecords`.
    /// @return List of all of the names currently indexed.
    function getApprovedRecords() public view returns (string[] memory) {
        return approvedRecordNames;
    }

    /// @notice Adds record `_recordName` to this sender's records if it is an approved record.
    /// @dev If record `_recordName` is on the approved list, then it is added to the sender's records.
    ///      Otherwise, the transaction is reverted with a `NotApproved` error loaded with the unapproved `_recordName`.
    /// @param _recordName The name of the record to add to the sender's records.
    function addRecord(string memory _recordName) public {
        if (!approvedRecords[_recordName]) {
            revert NotApproved(_recordName);
        }

        if (!userFavorites[msg.sender][_recordName]) {
            userFavorites[msg.sender][_recordName] = true;
            userFavoriteRecordsNames[msg.sender].push(_recordName);
        }
    }

    /// @notice Retrieves the list of favorites for any address.
    /// @param _address The user for which to look up the favorite records.
    /// @return The favorite records of user `_address`.
    function getUserFavorites(address _address) public view returns (string[] memory) {
        return userFavoriteRecordsNames[_address];
    }

    /// @notice Resets the list of favorites for the sender.
    /// @dev Resets `userFavorites` and `userFavoriteRecordsNames` for the sender.
    function resetUserFavorites() public {
        for (uint256 index = 0; index < approvedRecordNames.length; index++) {
            userFavorites[msg.sender][approvedRecordNames[index]] = false;
            delete userFavoriteRecordsNames[msg.sender];
        }
    }
}
