// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Manages cars in a garage
/// @author Roch
/// @notice Manages cars in a garage
/// @dev Implementation of a solution for https://docs.base.org/base-camp/docs/structs/structs-exercise
contract GarageManager {
    mapping(address => Car[]) public garage;
    Car[] internal cars;

    struct Car {
        string make;
        string model;
        string color;
        uint256 numberOfDoors;
    }

    error BadCarIndex(uint256 index);
    event CarAdded(address owner);
    event CarUpdated(address owner, uint256 index);
    event GarageReset(address owner);

    /// @notice Adds a car to the sender's collection in the `garage`.
    /// @param _make The make of the car.
    /// @param _model The model of the car.
    /// @param _color The color of the car.
    /// @param _numberOfDoors The number of doors of the car.
    function addCar(
        string calldata _make,
        string calldata _model,
        string calldata _color,
        uint256 _numberOfDoors
    ) public {
        garage[msg.sender].push(
            Car({
                numberOfDoors: _numberOfDoors,
                make: _make,
                model: _model,
                color: _color
            })
        );

        emit CarAdded(msg.sender);
    }

    /// @notice Returns an array with all of the cars owned by the sender.
    /// @return All of the cars owned by the sender.
    function getMyCars() public view returns (Car[] memory) {
        return garage[msg.sender];
    }

    /// @notice Returns an array with all of the cars for any given address.
    /// @return All of the cars for any given address.
    function getUserCars(address _user) public view returns (Car[] memory) {
        return garage[_user];
    }

    /// @notice Updates the car at index `_index` in the sender's garage with make `_make`,
    ///         model `_model`, color `_color`, number of doors `_numberOfDoors`.
    /// @dev If the sender doesn't have a car at that index, the function reverts with
    ///      custom error `BadCarIndex` and loaded with the index provided.
    /// @param _index Index of the car to be updated.
    /// @param _make The make of the car.
    /// @param _model The model of the car.
    /// @param _color The color of the car.
    /// @param _numberOfDoors The number of doors of the car.
    function updateCar(
        uint256 _index,
        string calldata _make,
        string calldata _model,
        string calldata _color,
        uint256 _numberOfDoors
    ) public {
        if (_index >= garage[msg.sender].length) {
            revert BadCarIndex(_index);
        }

        garage[msg.sender][_index] = Car({
            make: _make,
            model: _model,
            color: _color,
            numberOfDoors: _numberOfDoors
        });

        emit CarUpdated(msg.sender, _index);
    }

    /// @notice Deletes the entry in garage for the sender.
    function resetMyGarage() public {
        delete garage[msg.sender];
        
        emit GarageReset(msg.sender);
    }
}
