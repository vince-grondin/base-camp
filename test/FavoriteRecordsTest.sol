// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/FavoriteRecords.sol";

contract FavoriteRecordsTest is Test {
    string[] private approvedRecords = [
        "Thriller",
        "Back in Black",
        "The Bodyguard",
        "The Dark Side of the Moon",
        "Their Greatest Hits (1971-1975)",
        "Hotel California",
        "Come On Over",
        "Rumours",
        "Saturday Night Fever"
    ];
    
    address private user1 = vm.addr(1);
    address private user2 = vm.addr(2);

    FavoriteRecords favoriteRecords;

    function setUp() public {
        favoriteRecords = new FavoriteRecords(approvedRecords);
    }

    /// @dev Verifies that the array of records used to initialized `FavoriteRecords` is returned
    ///      when calling `getApprovedRecords`
    function test_WhenGettingApprovedRecords_ThenLoadedRecordsAreReturned() public {
        string[] memory result = favoriteRecords.getApprovedRecords();

        for (uint256 index = 0; index < approvedRecords.length; index++) {
            assertEq(approvedRecords[index], result[index]);
        }
    }

    /// @dev Verifies that adding an unapproved record fails
    function testFail_WhenAddingUnapprovedRecord() public {
        vm.startPrank(user1);
        favoriteRecords.addRecord(approvedRecords[3]);
        favoriteRecords.addRecord("Not an approved record");
        vm.stopPrank();

        favoriteRecords.getUserFavorites(user1);
    }

    /// @dev Verifies `getUserFavorites` returns approved records added by the sender identified by an address
    ///      and does not return records added to another user
    function test_GivenApprovedRecordsAdded_WhenGettingUserFavorites_ThenRecordReturnedForUser() public {
        vm.startPrank(user1);
        favoriteRecords.addRecord(approvedRecords[3]);
        favoriteRecords.addRecord(approvedRecords[6]);
        vm.stopPrank();

        string[] memory resultUser1 = favoriteRecords.getUserFavorites(user1);
        string[] memory resultUser2 = favoriteRecords.getUserFavorites(user2);

        assertEq(resultUser1.length, 2);
        assertEq(resultUser1[0], "The Dark Side of the Moon");
        assertEq(resultUser1[1], "Come On Over");
        assertEq(resultUser2.length, 0);
    }

    /// @dev Verifies that `resetUserFavorites` resets the records for the sender and not for any othe address
    function test_GivenApprovedRecordsAdded_WhenResetingUserFavorities_ThenRecordsAreResetForSender() public {
        vm.startPrank(user1);
        favoriteRecords.addRecord(approvedRecords[3]);
        favoriteRecords.addRecord(approvedRecords[6]);
        vm.stopPrank();

        vm.startPrank(user2);
        favoriteRecords.addRecord(approvedRecords[2]);
        favoriteRecords.addRecord(approvedRecords[1]);
        favoriteRecords.addRecord(approvedRecords[5]);
        vm.stopPrank();

        vm.startPrank(user1);
        favoriteRecords.resetUserFavorites();
        vm.stopPrank();

        assertEq(favoriteRecords.getUserFavorites(user1).length, 0);
        assertEq(favoriteRecords.getUserFavorites(user2).length, 3);
    }
}
