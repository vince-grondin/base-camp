// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Manages an address book
 * @author Roch
 * @notice Manages an address book
 * @dev Solution for the [New Exercise](https://docs.base.org/base-camp/docs/new-keyword/new-keyword-exercise)
 */
contract AddressBook is Ownable {
    Contact[] internal contacts;
    mapping(uint256 contactID => uint256 contactIndex)
        internal contactsIndexesByIDs;
    uint256 internal contactsCount = 0;

    struct Contact {
        uint256 id;
        string firstName;
        string lastName;
        uint256[] phoneNumbers;
    }

    error ContactNotFound(uint256 id);

    event ContactAdded(uint256 contactID, uint256 index);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Adds a given contact's information to `contacts`. Usable only by the owner of the contract.
     * @param _id The ID of the contact.
     * @param _firstName The first name of the contact.
     * @param _lastName The last name of the contact.
     * @param _phoneNumbers The phone numbers of the contact.
     */
    function addContact(
        uint256 _id,
        string memory _firstName,
        string memory _lastName,
        uint256[] memory _phoneNumbers
    ) external onlyOwner {
        contacts.push(
            Contact({
                id: _id,
                firstName: _firstName,
                lastName: _lastName,
                phoneNumbers: _phoneNumbers
            })
        );

        uint256 index = contacts.length - 1;
        contactsIndexesByIDs[_id] = index;
        contactsCount++;

        emit ContactAdded(_id, index);
    }

    /**
     * @notice Deletes the contact under the supplied `_id` number. Usable only by the owner of the contract. Reverts
     *         with a `ContactNotFound` error if not found.
     * @param _id The ID of the contact.
     */
    function deleteContact(uint256 _id) external onlyOwner contactExists(_id) {
        delete contacts[contactsIndexesByIDs[_id]];
        contactsIndexesByIDs[_id] = 0;
        contactsCount--;
    }

    /**
     * @notice Gets the contact information of the supplied `_id` number. Reverts with a `ContactNotFound` error if not
     *         found.
     * @param _id The ID of the contact.
     * @return The Contact
     */
    function getContact(
        uint256 _id
    ) external view contactExists(_id) returns (Contact memory) {
        return contacts[contactsIndexesByIDs[_id]];
    }

    /**
     * @notice Gets all of the user's current, non-deleted contacts.
     * @return allContacts All of the user's current, non-deleted contacts.
     */
    function getAllContacts()
        external
        view
        returns (Contact[] memory allContacts)
    {
        allContacts = new Contact[](contactsCount);

        uint256 cursor = 0;
        for (uint i = 0; i < contacts.length; i++) {
            Contact memory contact = contacts[i];
            uint256 contactID = contacts[i].id;

            if (contacts[contactsIndexesByIDs[contactID]].id == contactID) {
                allContacts[cursor++] = contact;
            }
        }

        return allContacts;
    }

    /**
     * @dev Checks that a contact identified by the supplied `_id` number exists. Reverts with a `ContactNotFound` error
     *      if not found.
     */
    modifier contactExists(uint256 _id) {
        if (
            contacts.length == 0 ||
            contacts[contactsIndexesByIDs[_id]].id != _id
        ) {
            revert ContactNotFound(_id);
        }
        _;
    }
}

/**
 * @title Factory to dynamically deploy instances of the `AddressBook` contract.
 * @author Roch
 * @notice Factory to dynamically deploy instances of the `AddressBook` contract.
 */
contract AddressBookFactory {
    /**
     * @notice Creates an instance of `AddressBook` and assigns the caller as the owner of that instance.
     * @return The address of the newly deployed `AddressBook` contract.
     */
    function deploy() external returns (address) {
        return address(new AddressBook());
    }
}
