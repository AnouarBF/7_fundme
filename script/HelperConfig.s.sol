// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockAggregatorV3.sol";

abstract contract Constant {
    uint8 public constant DECIMALS = 8;
    int public constant INITIAL_ANSWER = 2000;
    uint public constant SEPOLIA_CHAINID = 11155111;
    uint public constant ZKSYNC_CHAINID = 300;
}

contract HelperConfig is Constant, Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetwork;

    constructor() {
        if (block.chainid == SEPOLIA_CHAINID) {
            activeNetwork = get_Sepolia_config();
        } else if (block.chainid == ZKSYNC_CHAINID) {
            activeNetwork = get_ZKsync_sepolia_config();
        } else {
            activeNetwork = get_Anvil_config();
        }
    }

    function get_Sepolia_config() internal pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaPriceFeed = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaPriceFeed;
    }

    function get_ZKsync_sepolia_config()
        internal
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory zksyncSepoliaPriceFeed = NetworkConfig({
            priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        });

        return zksyncSepoliaPriceFeed;
    }

    function get_Anvil_config() internal returns (NetworkConfig memory) {
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }

        vm.startBroadcast();
        MockV3Aggregator mock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilPriceFeed = NetworkConfig({
            priceFeed: address(mock)
        });

        return anvilPriceFeed;
    }
}
