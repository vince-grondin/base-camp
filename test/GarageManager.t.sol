// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/GarageManager.sol";

contract GarageManagerTest is Test {
    GarageManager private garageManager;

    address private user1 = vm.addr(1);
    address private user2 = vm.addr(2);

    function carsFixtures(
        uint256 carIndex1,
        uint256 carIndex2,
        uint256 carIndex3
    )
        private
        pure
        returns (
            GarageManager.Car memory car1,
            GarageManager.Car memory car2,
            GarageManager.Car memory car3
        )
    {
        GarageManager.Car[3] memory cars = [
            GarageManager.Car({
                make: "Chrysler",
                model: "Voyager",
                color: "Silver",
                numberOfDoors: 5
            }),
            GarageManager.Car({
                make: "Honda",
                model: "Civic",
                color: "Black",
                numberOfDoors: 4
            }),
            GarageManager.Car({
                make: "Toyota",
                model: "Camry",
                color: "White",
                numberOfDoors: 4
            })
        ];

        uint256 maxIndex = cars.length - 1;

        car1 = cars[bound(carIndex1, 0, maxIndex)];
        car2 = cars[bound(carIndex2, 0, maxIndex)];
        car3 = cars[bound(carIndex3, 0, maxIndex)];

        return (car1, car2, car3);
    }

    function setUp() public {
        garageManager = new GarageManager();
    }

    /// @dev Verifies that only the cars that are added to the garage by a sender
    ///      are returned when the sender calls `getMyCars`.
    function test_GivenCarsAdded_WhenCallingGetMyCars_ThenSenderCarsReturned(
        uint256 carIndex1,
        uint256 carIndex2,
        uint256 carIndex3
    ) public {
        (
            GarageManager.Car memory car1,
            GarageManager.Car memory car2,
            GarageManager.Car memory car3
        ) = carsFixtures(carIndex1, carIndex2, carIndex3);

        vm.startPrank(user1);
        addCar(car1);
        addCar(car2);
        vm.stopPrank();

        vm.startPrank(user2);
        addCar(car3);
        vm.stopPrank();

        vm.startPrank(user1);
        GarageManager.Car[] memory result = garageManager.getMyCars();
        vm.stopPrank();

        assertEqCar(result[0], car1);
        assertEqCar(result[1], car2);
    }

    /// @dev Verifies that the cars that are added to the garage by any sender
    ///      are returned when the `getUserCars` is called with the address of the cars' owner.
    function test_GivenCarsAdded_WhenCallingGetUserCars_ThenCarsOwnedByAddressReturned(
        uint256 carIndex1,
        uint256 carIndex2,
        uint256 carIndex3
    ) public {
        (
            GarageManager.Car memory car1,
            GarageManager.Car memory car2,
            GarageManager.Car memory car3
        ) = carsFixtures(carIndex1, carIndex2, carIndex3);

        vm.startPrank(user1);
        addCar(car1);
        addCar(car2);
        vm.stopPrank();

        vm.startPrank(user2);
        addCar(car3);
        vm.stopPrank();

        GarageManager.Car[] memory user1Result = garageManager.getUserCars(
            user1
        );
        GarageManager.Car[] memory user2Result = garageManager.getUserCars(
            user2
        );

        assertEq(user1Result.length, 2);
        assertEqCar(user1Result[0], car1);
        assertEqCar(user1Result[1], car2);

        assertEq(user2Result.length, 1);
        assertEqCar(user2Result[0], car3);
    }

    /// @dev Verifies a car that was added can be updated
    function test_GivenCarsAdded_WhenUpdatingCarAtIndex_ThenCarAtIndexUpdated(
        uint256 carIndex1,
        uint256 carIndex2,
        uint256 carIndex3
    ) public {
        (
            GarageManager.Car memory car1,
            GarageManager.Car memory car2,
            GarageManager.Car memory car3
        ) = carsFixtures(carIndex1, carIndex2, carIndex3);

        GarageManager.Car memory carUpdates = GarageManager.Car({
            make: "Toyota",
            model: "Sienna",
            color: "Gold",
            numberOfDoors: uint256(5)
        });

        vm.startPrank(user1);
        addCar(car1);
        addCar(car2);
        vm.stopPrank();

        vm.startPrank(user2);
        addCar(car3);
        vm.stopPrank();

        vm.startPrank(user1);
        garageManager.updateCar(
            1,
            carUpdates.make,
            carUpdates.model,
            carUpdates.color,
            carUpdates.numberOfDoors
        );
        vm.stopPrank();

        GarageManager.Car[] memory user1Cars = garageManager.getUserCars(user1);

        assertEqCar(user1Cars[1], carUpdates);
    }

    /// @dev Verifies that a sender's garage can be reset
    function test_GivenCarsAdded_WhenResetingGarage_ThenSenderGarageReset(
        uint256 carIndex1,
        uint256 carIndex2,
        uint256 carIndex3
    ) public {
        (
            GarageManager.Car memory car1,
            GarageManager.Car memory car2,
            GarageManager.Car memory car3
        ) = carsFixtures(carIndex1, carIndex2, carIndex3);

        vm.startPrank(user1);
        addCar(car1);
        addCar(car2);
        vm.stopPrank();

        vm.startPrank(user2);
        addCar(car3);
        vm.stopPrank();

        vm.startPrank(user1);
        garageManager.resetMyGarage();
        vm.stopPrank();

        GarageManager.Car[] memory user1Result = garageManager.getUserCars(
            user1
        );
        GarageManager.Car[] memory user2Result = garageManager.getUserCars(
            user2
        );

        assertEq(user1Result.length, 0);
        assertEq(user2Result.length, 1);
    }

    /// @dev Helper function delegating to `garageManager`'s `addCar`
    function addCar(GarageManager.Car memory car) private {
        garageManager.addCar(car.make, car.model, car.color, car.numberOfDoors);
    }

    function assertEqCar(
        GarageManager.Car memory actual,
        GarageManager.Car memory expected
    ) private {
        assertEq(actual.numberOfDoors, expected.numberOfDoors);
        assertEq(actual.make, expected.make);
        assertEq(actual.model, expected.model);
        assertEq(actual.color, expected.color);
    }
}
