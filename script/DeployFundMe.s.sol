// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address private priceFeed;

    function run() external returns (FundMe) {
        HelperConfig config = new HelperConfig();
        priceFeed = config.activeNetwork();
        vm.startBroadcast(); //////////////////////////////////////////////////////////
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast(); ///////////////////////////////////////////////////////////

        return fundMe;
    }
}

/**
    Instance of HelperConfig created
    get the activeNetwork of Type NetworkConfig
    get the priceFeed of type address
 */
