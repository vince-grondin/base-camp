// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title String Utils specifically provided for the [Imports exercise](https://docs.base.org/base-camp/docs/imports/imports-exercise).
library SillyStringUtils {
    struct Haiku {
        string line1;
        string line2;
        string line3;
    }

    function shruggie(string memory _input) internal pure returns (string memory) {
        return string.concat(_input, unicode" 🤷");
    }
}

/// @title Maintains a Haiku and provides a function to add a shrug emoji at the end of line 3 of the Haiku.
/// @dev Implements a solution for the [Imports exercise](https://docs.base.org/base-camp/docs/imports/imports-exercise).
/// @author Roch
/// @notice
contract ImportsExercise {
    using SillyStringUtils for SillyStringUtils.Haiku;
    using SillyStringUtils for string;

    SillyStringUtils.Haiku public haiku;

    event HaikuSaved(string line1, string line2, string line3);

    /// @notice Loads the three `_line1`, `_line2` and `_line3` lines this contract.
    /// @param _line1 The first line of the `Haiku`.
    /// @param _line2 The second line of the `Haiku`.
    /// @param _line3 The third line of the `Haiku`.
    function saveHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public {
        haiku.line1 = _line1;
        haiku.line2 = _line2;
        haiku.line3 = _line3;

        emit HaikuSaved(haiku.line1, haiku.line2, haiku.line3);
    }

    /// @notice Gets the `Haiku`.
    /// @return The `Haiku`
    function getHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return haiku;
    }

    /// @notice Returns an instance of the `Haiku` after adding a shrug emoji at the end of `line3`.
    /// @return The `Haiku` with a shrug emoji added to line 3.
    function shruggieHaiku()
        public
        view
        returns (SillyStringUtils.Haiku memory)
    {
        return
            SillyStringUtils.Haiku({
                line1: haiku.line1,
                line2: haiku.line2,
                line3: haiku.line3.shruggie()
            });
    }
}
