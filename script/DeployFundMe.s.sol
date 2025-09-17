// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address private s_activeNetwork;

    function run() external returns (FundMe) {
        HelperConfig config = new HelperConfig();
        s_activeNetwork = config.activeNetwork();
        vm.startBroadcast(); //////////////////////////////////////////////////////////
        FundMe fundMe = new FundMe(s_activeNetwork);
        vm.stopBroadcast(); ///////////////////////////////////////////////////////////

        return fundMe;
    }
}

/**
    Instance of HelperConfig created
    get the activeNetwork of Type NetworkConfig
    get the priceFeed of type address
 */
