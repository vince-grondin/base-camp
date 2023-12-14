// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Defines the external behavior of the HaikuNFT contract implementation.
 * @author Roch
 */
interface IHaikuNFT {
    error HaikuNotUnique();
    error NoHaikusShared();
    error NotYourHaiku(uint haikuID);

    event HaikuMinted(uint haikuID);
    event HaikuShared(uint haikuID, address user);

    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    /**
     * @notice Mints new haiku with lines that are not present if any haiku previously minted.
     * @param _line1 The first line of the haiku.
     * @param _line2 The second line of the haiku.
     * @param _line3 The third line of the haiku.
     */
    function mintHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external;

    /**
     * @notice Shares an existing Haiku with another user.
     * @param _to The address of the user to share the Haiku with.
     * @param _haikuID The ID of a Haiku.
     */
    function shareHaiku(uint _haikuID, address _to) external;

    /**
     * @notice Gets an array containing all of the Haikus shared with the caller.
     * @return result All of the Haikus shared with the caller.
     */
    function getMySharedHaikus() external view returns (Haiku[] memory);
}

/**
 * @title A solution for the [ERC-721 Tokens Exercise](https://docs.base.org/base-camp/docs/erc-721-token/erc-721-exercise) exercise.
 * @author Roch
 */
contract HaikuNFT is ERC721, IHaikuNFT {
    using StringExtensions for string;

    Haiku[] public haikus;

    mapping(string => bool) internal lines;

    mapping(address => uint[] haikuIDs) internal sharedHaikus;

    uint public counter;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        counter = 1;
    }

    /// @inheritdoc IHaikuNFT
    function mintHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external {
        _validateLinesDoNotExist(_line1, _line2, _line3);
        lines[_line1] = true;
        lines[_line2] = true;
        lines[_line3] = true;

        uint id = counter;

        haikus.push(
            Haiku({
                author: msg.sender,
                line1: _line1,
                line2: _line2,
                line3: _line3
            })
        );

        counter++;

        _mint(msg.sender, id);

        emit HaikuMinted(id);
    }

    /// @inheritdoc IHaikuNFT
    function shareHaiku(
        uint _haikuID,
        address _to
    ) external ownsHaiku(_haikuID) {
        sharedHaikus[_to].push(_haikuID);
        emit HaikuShared(_haikuID, _to);
    }

    /// @inheritdoc IHaikuNFT
    function getMySharedHaikus() external view returns (Haiku[] memory result) {
        if (sharedHaikus[msg.sender].length == 0) revert NoHaikusShared();

        result = new Haiku[](sharedHaikus[msg.sender].length);

        for (uint i = 0; i < sharedHaikus[msg.sender].length; i++) {
            result[i] = haikus[sharedHaikus[msg.sender][i]];
        }

        return result;
    }

    /**
     * @dev Verifies that the sender own the Haiku identified by `_haikuID`. Reverts with a `NotYourHaiku` if
     *      sender is not the owner.
     * @param _haikuID The ID of a Haiku.
     */
    modifier ownsHaiku(uint _haikuID) {
        if (ownerOf(_haikuID) != msg.sender) revert NotYourHaiku(_haikuID);
        _;
    }

    /**
     * @dev Validates that none of the supplied `_line1`, `_line2`, `_line3` exist in the `lines` set. Reverts with a
     *      `HaikuNotUnique` error if any of the lines exist.
     * @param _line1 A line.
     * @param _line2 A line.
     * @param _line3 A line
     */
    function _validateLinesDoNotExist(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) private view {
        if (lines[_line1] || lines[_line2] || lines[_line3])
            revert HaikuNotUnique();
    }
}

/**
 * @title Provides extension functions for strings.
 * @author Roch
 */
library StringExtensions {
    /**
     * @dev Converts the string to bytes and computes the hash of the bytes.
     * @param _string The string to convert to bytes.
     */
    function toBytes(string memory _string) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string));
    }
}
