// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetwork();
        } else {
            activeNetworkConfig = getAnvilNetwork();
        }
    }

    function getSepoliaNetwork() public pure returns (NetworkConfig memory) {
        NetworkConfig memory priceFeed = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed;
    }

    // We defined the anvil network this way cause the anvil network runs with or without an additional network. Wich means that we need
    // a way to make sure our contract is stored in the anvil network.

    function getAnvilNetwork() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(
            address(mockPriceFeed)
        );
        return anvilConfig;
    }
}

// Here is that helper file you can add as many networks as you want. just create a function that defines the network address and then pass the
// condition to the constructor.
