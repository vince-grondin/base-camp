// SPDX-License-Identifier: MIT 
pragma solidity 0.8.17;

/// @title A contract that performs basic array manipulations.
/// @author Roch
/// @notice You can use this contract to validate the behavior of arrays.
contract ArraysExercise {
    uint256[] public numbers = [1,2,3,4,5,6,7,8,9,10];
    address[] public senders;
    uint256[] public timestamps;
    uint256 public afterYear2kTimestampsCount;

    /// @notice Returns all numbers from the `numbers` storage array.
    /// @return numbers All the current numbers
    function getNumbers() external view returns(uint256[] memory) {
        return numbers;
    }

    /// @notice Resets the `numbers` storage array to its initial value, holding the numbers from 1-10.
    function resetNumbers() public {
        delete numbers;
        numbers = [1,2,3,4,5,6,7,8,9,10];
    }

    /// @notice Adds the `_toAppend` array to the `numbers` storage array.
    /// @param _toAppend An array of items to append to the items already loaded in the `numbers` storage array.
    function appendToNumbers(uint256[] calldata _toAppend) external {
        for (uint256 index = 0; index < _toAppend.length; index++) {
            numbers.push(_toAppend[index]);
        }
    }

    /// @notice Adds the address of the caller to the `senders` storage array
    /// and adds `_unixTimestamp` to the `timestamps` storage array.
    /// @dev Both items are added at the same index in their respective array. They are in sync.
    /// @param _unixTimestamp The timestamp of the operation
    function saveTimestamp(uint256 _unixTimestamp) external {
        senders.push(msg.sender);
        timestamps.push(_unixTimestamp);

        if (isRecentTimestamp(_unixTimestamp)) {
            afterYear2kTimestampsCount++;
        }
    }

    /// @notice Returns timestamps that are more recent than January 1, 2000, 12:00am
    /// and the senders that have interacted with this contract after this date.
    /// @return recentTimestamps The timestamps that are more recent than January 1, 2000, 12:00am.
    /// @return recentSenders The senders that interacted with this contract after January 1, 2000, 12:00am.
    function afterY2K() external view returns(uint256[] memory recentTimestamps, address[] memory recentSenders) {
        uint256 cursor;
        recentTimestamps = new uint256[](afterYear2kTimestampsCount);
        recentSenders = new address[](afterYear2kTimestampsCount);

        for (uint256 index = 0; index < timestamps.length; index++) {
            if (isRecentTimestamp(timestamps[index])) {
                recentTimestamps[cursor] = timestamps[index];
                recentSenders[cursor] = senders[index];
                cursor++;
            }
        }
    }

    /// @notice Checks whether `_timestamp` is more recent than January 1, 2000, 12:00am.
    /// @return Whether the `_timestamp` is more recent that January 1, 2000, 12:00am.
    function isRecentTimestamp(uint256 _timestamp) private pure returns(bool) {
        return _timestamp > 946702800;
    }

    /// @notice Resets the `senders` array.
    function resetSenders() external {
        delete senders;
    }

    /// @notice Resets the `timestamps` array.
    function resetTimestamps() external {
        delete timestamps;
        delete afterYear2kTimestampsCount;
    }
}
