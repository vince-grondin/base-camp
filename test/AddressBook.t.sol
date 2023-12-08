// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/AddressBook.sol";

/**
 * @title Verifies the behavior of the `AddressBook` contract.
 * @author Roch
 */
contract AddressBookTest is Test {
    AddressBook private addressBook;

    /**
     * @dev Gets `AddressBook.Contact` test fixtures.
     * @return An array of 3 `AddressBook.Contact` test fixtures.
     */
    function contactsFixtures()
        private
        pure
        returns (AddressBook.Contact[3] memory)
    {
        uint256[] memory phoneNumbers = new uint256[](1);
        phoneNumbers[0] = 43;

        return [
            AddressBook.Contact({
                id: 10,
                firstName: "ABC",
                lastName: "DEF",
                phoneNumbers: phoneNumbers
            }),
            AddressBook.Contact({
                id: 8,
                firstName: "HIJ",
                lastName: "KLM",
                phoneNumbers: phoneNumbers
            }),
            AddressBook.Contact({
                id: 3,
                firstName: "NOP",
                lastName: "QRS",
                phoneNumbers: phoneNumbers
            })
        ];
    }

    address private userA = address(1);
    address private userB = address(2);

    event ContactAdded(uint256 contactID, uint256 index);

    function setUp() public {
        vm.startPrank(userA);
        addressBook = new AddressBook();
    }

    /**
     * @dev Verifies that `addContact` reverts with `OwnableUnauthorizedAccount` when called by a user different than
     *      the owner of the contract when no contacts exist.
     * @param _contactIndex The index of the contacts to use from the contacts fixtures.
     */
    function test_GivenNoContactsExists_AndSenderNotOwner_WhenAdding_ThenOwnableUnauthorizedAccountError(
        uint256 _contactIndex
    ) public {
        vm.stopPrank();
        vm.assume(_contactIndex <= 2);
        AddressBook.Contact memory contact = contactsFixtures()[_contactIndex];

        vm.startPrank(userB);
        expectRevertOwnableUnauthorizedAccount(userB);
        addContact(contact);
    }

    /**
     * @dev Verifies that `addContact` reverts with `OwnableUnauthorizedAccount` when called by a user different than
     *      the owner of the contract when contacts already exist.
     * @param _contactIndexA The index of the contacts to use from the contacts fixtures.
     */
    function test_GivenContactsExist_AndSenderNotOwner_WhenAdding_ThenOwnableUnauthorizedAccountError(
        uint256 _contactIndexA,
        uint256 _contactIndexB
    ) public {
        vm.assume(_contactIndexA <= 2);
        vm.assume(_contactIndexB <= 2);
        AddressBook.Contact[3] memory _contactsFixtures = contactsFixtures();

        addContact(_contactsFixtures[_contactIndexA]);

        vm.startPrank(userB);
        expectRevertOwnableUnauthorizedAccount(userB);
        addContact(_contactsFixtures[_contactIndexB]);
    }

    /**
     * @dev Verifies that `addContact` adds a single contact for the sender when they are the owner and there are no
     *      existing contacts.
     * @param _contactIndex The index of the contact in the contacts fixtures to add to the address book.
     */
    function test_GivenNoContactsExists_AndSenderIsOwner_WhenAdding_ThenContactAdded(
        uint256 _contactIndex
    ) public {
        vm.assume(_contactIndex <= 2);
        AddressBook.Contact[3] memory _contactsFixtures = contactsFixtures();
        AddressBook.Contact memory contact = _contactsFixtures[_contactIndex];

        vm.expectEmit(true, true, true, true, address(addressBook));
        emit ContactAdded(contact.id, 0);

        addContact(contact);

        AddressBook.Contact[] memory contacts = addressBook.getAllContacts();
        assertEq(contacts.length, 1);
        assertEqContact(contacts[0], contact);
    }

    /**
     * @dev Verifies that `addContact` adds a single contact for the sender when they are the owner and there are
     *      existing contacts.
     * @param _contactIndexA The index of the first contact in the contacts fixtures to add to the address book.
     * @param _contactIndexB The index of the second contact in the contacts fixtures to add to the address book.
     */
    function test_GivenContactsExist_AndSenderIsOwner_WhenAdding_ThenContactAdded(
        uint256 _contactIndexA,
        uint256 _contactIndexB
    ) public {
        vm.assume(_contactIndexA <= 2);
        vm.assume(_contactIndexB <= 2);
        vm.assume(_contactIndexA != _contactIndexB);
        AddressBook.Contact[3] memory _contactsFixtures = contactsFixtures();
        AddressBook.Contact memory contactA = _contactsFixtures[_contactIndexA];
        AddressBook.Contact memory contactB = _contactsFixtures[_contactIndexB];

        addContact(contactA);

        vm.expectEmit(true, true, true, true, address(addressBook));
        emit ContactAdded(contactB.id, 1);

        addContact(contactB);

        AddressBook.Contact[] memory contacts = addressBook.getAllContacts();
        assertEq(contacts.length, 2);
        assertEqContact(contacts[0], contactA);
        assertEqContact(contacts[1], contactB);
    }

    /**
     * @dev Verifies that `deleteContact` reverts with a `ContactNotFound` error when there are no contacts.
     * @param _id The ID of the contact to delete.
     */
    function test_GivenNoContactExists_AndSenderOwner_WhenDeleting_ThenContactNotFoundRevert(
        uint256 _id
    ) public {
        expectRevertContactNotFound(_id);

        addressBook.deleteContact(_id);
    }

    /**
     * @dev Verifies that `deleteContact` reverts with a `OwnableUnauthorizedAccount` error where there are contacts
     *      and the sender is not the owner.
     * @param _contactIndex The index of the contact in the contacts fixtures to add to the address book.
     */
    function test_GivenContactExists_AndSenderNotOwner_WhenDeletingExistingContact_ThenOwnableUnauthorizedAccountRevert(
        uint256 _contactIndex
    ) public {
        vm.assume(_contactIndex <= 2);
        AddressBook.Contact memory contact = contactsFixtures()[_contactIndex];
        addContact(contact);
        vm.stopPrank();

        expectRevertOwnableUnauthorizedAccount(userB);
        vm.startPrank(userB);
        addressBook.deleteContact(contact.id);
    }

    /**
     * @dev Verifies that `deleteContact` reverts with a `ContactNotFound` error when there are contacts
     *      and the sender is the owner but the contact does not exist.
     * @param _contactIndex The index of the contact in the contacts fixtures to add to the address book.
     */
    function test_GivenContactExists_AndSenderOwner_WhenDeletingNonExistingContact_ThenContactNotFoundRevert(
        uint256 _contactIndex
    ) public {
        vm.assume(_contactIndex <= 2);
        AddressBook.Contact memory contact = contactsFixtures()[_contactIndex];
        addContact(contact);

        expectRevertContactNotFound(99);
        addressBook.deleteContact(99);
    }

    /**
     * @dev Verifies that `getContact` reverts with a `ContactNotFound` error when there are no existing contacts.
     */
    function test_GivenNoContactsExist_WhenGettingContact_ThenContactNotFoundRevert()
        public
    {
        expectRevertContactNotFound(99);
        addressBook.getContact(99);
    }

    /**
     * @dev Verifies that `getContact` reverts with a `ContactNotFound` error where there are existing contacts
     *      no contact exists for `_id`.
     * @param _contactIndex The index of the contact in the contacts fixtures to add to the address book.
     */
    function test_GivenContactsExists_WhenGettingNonExistingContact_ThenContactNotFoundRevert(
        uint256 _contactIndex
    ) public {
        vm.assume(_contactIndex <= 2);
        AddressBook.Contact memory contact = contactsFixtures()[_contactIndex];
        addContact(contact);

        expectRevertContactNotFound(99);
        addressBook.getContact(99);
    }

    /**
     * @dev Verifies that `getContact` returns the contact when it exists.
     * @param _contactIndexA The index of the first contact in the contacts fixtures to add to the address book.
     * @param _contactIndexB The index of the second contact in the contacts fixtures to add to the address book.
     */
    function test_GivenContactsExists_WhenGettingExistingContact_ThenContactReturned(
        uint256 _contactIndexA,
        uint256 _contactIndexB
    ) public {
        vm.assume(_contactIndexA <= 2);
        vm.assume(_contactIndexB <= 2);
        vm.assume(_contactIndexA != _contactIndexB);
        AddressBook.Contact[3] memory _contactsFixtures = contactsFixtures();
        AddressBook.Contact memory contactA = _contactsFixtures[_contactIndexA];
        AddressBook.Contact memory contactB = _contactsFixtures[_contactIndexB];
        addContact(contactA);
        addContact(contactB);

        AddressBook.Contact memory result = addressBook.getContact(contactA.id);

        assertEqContact(result, contactA);
    }

    /**
     * @dev Verifies that `getContact` returns the contact when it exists.
     * @param _contactIndexA The index of the first contact in the contacts fixtures to add to the address book.
     * @param _contactIndexB The index of the second contact in the contacts fixtures to add to the address book.
     */
    function test_GivenContactsAdded_AndDeleted_WhenGettingContact_ThenContactNotFoundRevert(
        uint256 _contactIndexA,
        uint256 _contactIndexB
    ) public {
        vm.assume(_contactIndexA <= 2);
        vm.assume(_contactIndexB <= 2);
        vm.assume(_contactIndexA != _contactIndexB);
        AddressBook.Contact[3] memory _contactsFixtures = contactsFixtures();
        AddressBook.Contact memory contactA = _contactsFixtures[_contactIndexA];
        AddressBook.Contact memory contactB = _contactsFixtures[_contactIndexB];
        addContact(contactA);
        addContact(contactB);
        addressBook.deleteContact(contactA.id);

        expectRevertContactNotFound(contactA.id);
        addressBook.getContact(contactA.id);
    }

    /**
     * @dev Verifies that `getAllContacts` returns all of the non-deleted contacts.
     */
    function test_GivenContactsAdded_AndSomeDeleted_WhenGettingAllContacts_ThenNonDeletedContactsReturned()
        public
    {
        AddressBook.Contact[3] memory _contactsFixtures = contactsFixtures();
        AddressBook.Contact memory contactA = _contactsFixtures[2];
        AddressBook.Contact memory contactB = _contactsFixtures[0];
        AddressBook.Contact memory contactC = _contactsFixtures[1];
        addContact(contactA);
        addContact(contactB);
        addContact(contactC);
        addressBook.deleteContact(contactB.id);

        AddressBook.Contact[] memory result = addressBook.getAllContacts();

        assertEq(result.length, 2);
        assertEqContact(result[0], contactA);
        assertEqContact(result[1], contactC);
    }

    /**
     * @dev Helper function that delegates to `AddressBook#addContact`
     * @param contact The contact to add.
     */
    function addContact(AddressBook.Contact memory contact) private {
        addressBook.addContact(
            contact.id,
            contact.firstName,
            contact.lastName,
            contact.phoneNumbers
        );
    }

    /**
     * @dev Asserts that `_actual` contact equals `_expected` contact.
     * @param _actual The contact to assert.
     * @param _expected The contact to assert against.
     */
    function assertEqContact(
        AddressBook.Contact memory _actual,
        AddressBook.Contact memory _expected
    ) private {
        assertEq(
            keccak256(abi.encode(_actual)),
            keccak256(abi.encode(_expected))
        );
    }

    /**
     * Verifies that a `OwnableUnauthorizedAccount` revert occurs for the supplied `_sender`.
     * @param _sender The sender address.
     */
    function expectRevertOwnableUnauthorizedAccount(address _sender) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                _sender
            )
        );
    }

    /**
     * Verifies that a `ContactNotFound` revert occurs for the supplied `_id`.
     * @param _id The ID.
     */
    function expectRevertContactNotFound(uint256 _id) private {
        vm.expectRevert(
            abi.encodeWithSelector(AddressBook.ContactNotFound.selector, _id)
        );
    }
}
