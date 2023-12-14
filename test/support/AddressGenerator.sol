// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title Provides functions to generate addresses.
 * @author Roch
 */
library AddressGenerator {
    /**
     * @dev Maps a uint `_address` representation to an address.
     * @param _address The uint representation of the address.
     */
    function toAddress(uint _address) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(_address)))));
    }
}
