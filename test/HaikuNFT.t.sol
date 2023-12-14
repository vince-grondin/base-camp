// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "./support/AddressGenerator.sol";
import "../src/HaikuNFT.sol";

/**
 * @title Verifies the behavior of the HaikuNFT contract.
 * @author Roch
 */
contract HaikuNFTTest is Test {
    using AddressGenerator for uint;

    HaikuNFT private haikuNFT;

    address private userA = address(1);
    address private userB = address(2);
    address private userC = address(3);

    event HaikuShared(uint haikuID, address user);

    /**
     * @dev Returns an array of Haikus
     */
    function haikuFixtures() private view returns (IHaikuNFT.Haiku[3] memory) {
        return [
            IHaikuNFT.Haiku({
                author: userA,
                line1: "Autumn leaves falling,",
                line2: "Whispers of a quiet breeze,",
                line3: "Nature's dance unfolds."
            }),
            IHaikuNFT.Haiku({
                author: userC,
                line1: "Beneath moonlit skies,",
                line2: "Silent waves caress the shore,",
                line3: "Night's embrace is calm."
            }),
            IHaikuNFT.Haiku({
                author: userB,
                line1: "Cherry blossoms bloom,",
                line2: "Petals dancing in the breeze,",
                line3: "Spring's sweet melody."
            })
        ];
    }

    function setUp() public {
        haikuNFT = new HaikuNFT("HaikuNFT", "HNFT");
    }

    /**
     * @dev Verifies that minting a Haiku for the first time succeeds.
     * @param _haikuFixtureIndex The index of the Haiku to use from the Haiku test fixtures array.
     */
    function xtest_GivenNoNFTsMintedYet_WhenMinting_ThenSuccess(
        uint8 _haikuFixtureIndex
    ) public {
        vm.assume(_haikuFixtureIndex < 3);

        _mintHaiku(haikuFixtures()[_haikuFixtureIndex]);

        assertEq(haikuNFT.counter(), 2);
    }

    /**
     * @dev Verifies that minting a Haiku after one or more Haikus were minted succeeds.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     */
    function xtest_GivenNFTsMinted_WhenMinting_ThenSuccess(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3
    ) public {
        _assumeDistinctHaikuFixtureIndexes(
            _haikuFixtureIndex1,
            _haikuFixtureIndex2,
            _haikuFixtureIndex3
        );

        IHaikuNFT.Haiku[3] memory _haikuFixtures = haikuFixtures();

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex1]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex2]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex3]);

        assertEq(haikuNFT.counter(), 4);
    }

    /**
     * @dev Verifies that minting a Haiku with a line that is already present in any of the Haiku previously minted
     *      reverts with a `IHaikuNFT.HaikuNotUnique` error.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     */
    function xtest_GivenAnyLineExists_WhenMinting_ThenHaikuNotUniqueRevert(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3
    ) public {
        _assumeDistinctHaikuFixtureIndexes(
            _haikuFixtureIndex1,
            _haikuFixtureIndex2,
            _haikuFixtureIndex3
        );

        IHaikuNFT.Haiku[3] memory _haikuFixtures = haikuFixtures();

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex1]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex2]);
        IHaikuNFT.Haiku memory haikuWithSameLine = _haikuFixtures[
            _haikuFixtureIndex3
        ];
        haikuWithSameLine.line2 = _haikuFixtures[_haikuFixtureIndex2].line3;

        vm.expectRevert(
            abi.encodeWithSelector(IHaikuNFT.HaikuNotUnique.selector)
        );

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex3]);

        assertEq(haikuNFT.counter(), 3);
    }

    /**
     * @dev Verifies that sharing a Haiku that does not exist reverts with a `IHaikuNFT.NotYourHaiku` error.
     * @param _haikuFixtureIndex The index of the Haiku to use from the Haiku test fixtures array.
     * @param _to The address of the user to share the Haiku with.
     * @param _nonExistingHaikuID The ID of the Haiku that does not exist.
     */
    function xtest_GivenHaikuNotExists_WhenSharing_ThenNotYourHaikuRevert(
        uint8 _haikuFixtureIndex,
        uint256 _to,
        uint8 _nonExistingHaikuID
    ) public {
        vm.assume(_haikuFixtureIndex < 3);
        vm.assume(_to > 3);
        vm.assume(_nonExistingHaikuID > 1);

        IHaikuNFT.Haiku memory haikuFixture = haikuFixtures()[
            _haikuFixtureIndex
        ];
        _mintHaiku(haikuFixture);

        vm.startPrank(haikuFixture.author);
        _expectNotYourHaikuRevert(_nonExistingHaikuID);

        haikuNFT.shareHaiku(_nonExistingHaikuID, _to.toAddress());
    }

    /**
     * @dev Verifies that sharing a Haiku owned by a user other than the sender reverts with a `IHaikuNFT.NotYourHaiku`
     *      error.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     * @param _to The address of the user to share the Haiku with.
     */
    function xtest_GivenHaikuExists_AndNotOwnedBySender_WhenSharing_ThenNotYourHaikuRevert(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3,
        uint256 _to
    ) public {
        _assumeDistinctHaikuFixtureIndexes(
            _haikuFixtureIndex1,
            _haikuFixtureIndex2,
            _haikuFixtureIndex3
        );
        vm.assume(_to > 3);

        IHaikuNFT.Haiku[3] memory _haikuFixtures = haikuFixtures();

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex1]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex2]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex3]);

        vm.startPrank(_haikuFixtures[_haikuFixtureIndex2].author);
        _expectNotYourHaikuRevert(1);

        haikuNFT.shareHaiku(1, _to.toAddress());
    }

    /**
     * @dev Verifies that when a Haiku exists and the owner calls `shareHaiku` then it succeeds.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     * @param _to The address of the user to share the Haiku with.
     */
    function xtest_GivenHaikuExists_AndOwnedBySender_WhenSharing_ThenSuccess(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3,
        uint256 _to
    ) public {
        _assumeDistinctHaikuFixtureIndexes(
            _haikuFixtureIndex1,
            _haikuFixtureIndex2,
            _haikuFixtureIndex3
        );
        vm.assume(_to > 3);

        IHaikuNFT.Haiku[3] memory _haikuFixtures = haikuFixtures();

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex1]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex2]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex3]);

        address sender = _haikuFixtures[_haikuFixtureIndex2].author;
        vm.startPrank(sender);

        vm.expectEmit(true, true, true, true, address(haikuNFT));
        emit HaikuShared(2, _to.toAddress());

        haikuNFT.shareHaiku(2, _to.toAddress());
    }

    /**
     * @dev Verifies that calling `getMySharedHaikus` when no Haikus were shared with the sender reverts with a
     *      `NoHaikusShared` error.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     * @param _sender The address of the user that doesn't have any shared Haikus.
     */
    function test_GivenNoHaikusSharedWithSender_WhenGettingMySharedHaikus_ThenNoHaikusSharedRevert(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3,
        uint256 _sender
    ) public {
        _assumeDistinctHaikuFixtureIndexes(
            _haikuFixtureIndex1,
            _haikuFixtureIndex2,
            _haikuFixtureIndex3
        );
        vm.assume(_sender > 3);

        IHaikuNFT.Haiku[3] memory _haikuFixtures = haikuFixtures();

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex1]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex2]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex3]);

        vm.startPrank(_haikuFixtures[_haikuFixtureIndex3].author);
        haikuNFT.shareHaiku(3, uint(6).toAddress());
        vm.stopPrank();

        vm.startPrank(_haikuFixtures[_haikuFixtureIndex2].author);
        haikuNFT.shareHaiku(2, uint(9).toAddress());
        vm.stopPrank();

        vm.startPrank(_sender.toAddress());
        _expectNoHaikusSharedRevert();
        IHaikuNFT.Haiku[] memory result = haikuNFT.getMySharedHaikus();

        assertEq(result.length, 0);
    }

    /**
     * @dev Verifies that as many Haikus as were shared with the sender are returned when calling `getMySharedHaikus`
     *      after Haikus were shared with the sender.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     * @param _to The address of the user to share the Haiku with.
     */
    function xtest_GivenHaikusSharedSender_WhenGettingMySharedHaikus_ThenHaikusSharedWithSenderReturned(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3,
        uint256 _to
    ) public {
        _assumeDistinctHaikuFixtureIndexes(
            _haikuFixtureIndex1,
            _haikuFixtureIndex2,
            _haikuFixtureIndex3
        );
        vm.assume(_to > 3);

        IHaikuNFT.Haiku[3] memory _haikuFixtures = haikuFixtures();

        _mintHaiku(_haikuFixtures[_haikuFixtureIndex1]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex2]);
        _mintHaiku(_haikuFixtures[_haikuFixtureIndex3]);

        vm.startPrank(_haikuFixtures[_haikuFixtureIndex3].author);
        haikuNFT.shareHaiku(3, _to.toAddress());
        vm.stopPrank();

        vm.startPrank(_haikuFixtures[_haikuFixtureIndex2].author);
        haikuNFT.shareHaiku(2, _to.toAddress());
        vm.stopPrank();

        vm.startPrank(_haikuFixtures[_haikuFixtureIndex1].author);
        haikuNFT.shareHaiku(1, uint(99).toAddress());
        vm.stopPrank();

        vm.startPrank(_to.toAddress());
        IHaikuNFT.Haiku[] memory result = haikuNFT.getMySharedHaikus();

        assertEq(result.length, 2);
        assertEqHaiku(result[0], _haikuFixtures[_haikuFixtureIndex3]);
        assertEqHaiku(result[1], _haikuFixtures[_haikuFixtureIndex2]);
    }

    /**
     * @dev Asserts that an `_actual` Haiku equals an `_expected` Haiku.
     * @param _actual The Haiku to assert against the `_expected` Haiku.
     * @param _expected The Haiku to assert the `_actual` Haiku against.
     */
    function assertEqHaiku(
        IHaikuNFT.Haiku memory _actual,
        IHaikuNFT.Haiku memory _expected
    ) private {
        assertEq(
            keccak256(abi.encode(_actual)),
            keccak256(abi.encode(_expected))
        );
    }

    /**
     * @dev Reinitializes the supplied arguments so that they each correspond to an index of the Haiku test fixtures and
     *      are distinct.
     * @param _haikuFixtureIndex1 The index of the first Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex2 The index of the second Haiku to use from the Haiku test fixtures array.
     * @param _haikuFixtureIndex3 The index of the third Haiku to use from the Haiku test fixtures array.
     */
    function _assumeDistinctHaikuFixtureIndexes(
        uint8 _haikuFixtureIndex1,
        uint8 _haikuFixtureIndex2,
        uint8 _haikuFixtureIndex3
    ) private pure {
        vm.assume(
            _haikuFixtureIndex1 < 3 &&
                _haikuFixtureIndex2 < 3 &&
                _haikuFixtureIndex3 < 3
        );
        vm.assume(
            _haikuFixtureIndex1 != _haikuFixtureIndex2 &&
                _haikuFixtureIndex1 != _haikuFixtureIndex3
        );
        vm.assume(_haikuFixtureIndex2 != _haikuFixtureIndex3);
    }

    /**
     * @dev Asserts that an `IHaikuNFT.NoHaikusShared` occurs.
     */
    function _expectNoHaikusSharedRevert() private {
        vm.expectRevert(
            abi.encodeWithSelector(IHaikuNFT.NoHaikusShared.selector)
        );
    }

    /**
     * @dev Asserts that an `IHaikuNFT.NotYourHaiku` occurs.
     * @param _nonExistingHaikuID The ID of the Haiku that does not exist.
     */
    function _expectNotYourHaikuRevert(uint _nonExistingHaikuID) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                IHaikuNFT.NotYourHaiku.selector,
                _nonExistingHaikuID
            )
        );
    }

    /**
     * @dev Helper function to mint a Haiku using a Haiku test fixture's author as the sender and the other Haiku
     *      attributes.
     * @param haikuFixture A Haiku fixture to mint.
     */
    function _mintHaiku(IHaikuNFT.Haiku memory haikuFixture) private {
        vm.startPrank(haikuFixture.author);
        haikuNFT.mintHaiku(
            haikuFixture.line1,
            haikuFixture.line2,
            haikuFixture.line3
        );
        vm.stopPrank();
    }
}
