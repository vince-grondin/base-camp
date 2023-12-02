// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ImportsExercise.sol";

/// @title Verifies the behavior of the `ImportsExercise` contract
/// @author Roch
contract ImportsExerciseTest is Test {
    using SillyStringUtils for SillyStringUtils.Haiku;
    ImportsExercise importsExercise;

    event HaikuSaved(string line1, string line2, string line3);

    function setUp() public {
        importsExercise = new ImportsExercise();
    }

    /// Verifies that a `Haiku` can be saved when no `Haiku` was previously saved.
    /// @param _line1 The first line of the `Haiku`, fuzzy-generated.
    /// @param _line2 The second line of the `Haiku`, fuzzy-generated.
    /// @param _line3 The third line of the `Haiku`, fuzzy-generated.
    function test_GivenNoHaikuSaved_WhenSaving_ThenTheLinesAreLoaded(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public {
        vm.expectEmit(true, true, true, true, address(importsExercise));
        emit HaikuSaved(_line1, _line2, _line3);

        importsExercise.saveHaiku(_line1, _line2, _line3);
    }

    /// Verifies that a `Haiku` can be saved afer a `Haiku` was already saved.
    /// @param _line1 The first line of the `Haiku`, fuzzy-generated.
    /// @param _line2 The second line of the `Haiku`, fuzzy-generated.
    /// @param _line3 The third line of the `Haiku`, fuzzy-generated.
    function test_GivenExistingHaiku_WhenSaving_ThenTheNewLinesAreLoaded(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public {
        importsExercise.saveHaiku(
            "Existing Haiku Line 1",
            "Existing Haiku Line 2",
            "Existing Haiku Line 3"
        );

        vm.expectEmit(true, true, true, true, address(importsExercise));
        emit HaikuSaved(_line1, _line2, _line3);

        importsExercise.saveHaiku(_line1, _line2, _line3);
    }

    /// @dev Verifies getting a `Haiku` before any `Haiku` is saved returns an empty `Haiku`.
    function test_GivenNoHaikuSaved_WhenGetting_ThenEmptyHaikuReturned()
        public
    {
        SillyStringUtils.Haiku memory result = importsExercise.getHaiku();

        assertEqHaiku(
            result,
            SillyStringUtils.Haiku({line1: "", line2: "", line3: ""})
        );
    }

    /// @dev Verifies getting a `Haiku` after saving for the first time one returns the `Haiku`.
    /// @param _line1 The first line of the `Haiku`, fuzzy-generated.
    /// @param _line2 The second line of the `Haiku`, fuzzy-generated.
    /// @param _line3 The third line of the `Haiku`, fuzzy-generated.
    function test_GivenHaikuSaved_WhenGetting_ThenHaikuReturned(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public {
        importsExercise.saveHaiku(_line1, _line2, _line3);

        SillyStringUtils.Haiku memory result = importsExercise.getHaiku();

        assertEqHaiku(
            result,
            SillyStringUtils.Haiku({
                line1: _line1,
                line2: _line2,
                line3: _line3
            })
        );
    }

    /// @dev Verifies getting a `Haiku` after saving another one returns the latest `Haiku`.
    /// @param _line1 The first line of the `Haiku`, fuzzy-generated.
    /// @param _line2 The second line of the `Haiku`, fuzzy-generated.
    /// @param _line3 The third line of the `Haiku`, fuzzy-generated.
    function test_GivenTwoHaikusSaved_WhenGetting_ThenLatestHaikuReturned(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public {
        importsExercise.saveHaiku(
            "Existing Haiku Line 1",
            "Existing Haiku Line 2",
            "Existing Haiku Line 3"
        );

        importsExercise.saveHaiku(_line1, _line2, _line3);

        SillyStringUtils.Haiku memory result = importsExercise.getHaiku();

        assertEqHaiku(
            result,
            SillyStringUtils.Haiku({
                line1: _line1,
                line2: _line2,
                line3: _line3
            })
        );
    }

    /// @dev Verifies calling `shruggieHaiku` returns a `Haiku` with a shrug emoji added to line 3.
    /// @param _line1 The first line of the `Haiku`, fuzzy-generated.
    /// @param _line2 The second line of the `Haiku`, fuzzy-generated.
    function test_GivenHaikuSaved_WhenAddingShrugToHaiku_ThenHaikuWithShrugReturned(
        string memory _line1,
        string memory _line2
    ) public {
        importsExercise.saveHaiku(_line1, _line2, "Line 3");

        SillyStringUtils.Haiku memory result = importsExercise.shruggieHaiku();

        assertEqHaiku(
            result,
            SillyStringUtils.Haiku({
                line1: _line1,
                line2: _line2,
                line3: unicode"Line 3 🤷"
            })
        );
    }

    /// Asserts that `actual` `Haiku` equals `expected` `Haiku`.
    /// @param actual The `Haiku` to assert.
    /// @param expected The `Haiku` to assert against.
    function assertEqHaiku(
        SillyStringUtils.Haiku memory actual,
        SillyStringUtils.Haiku memory expected
    ) private {
        assertEq(actual.line1, expected.line1);
        assertEq(actual.line2, expected.line2);
        assertEq(actual.line3, expected.line3);
    }
}
