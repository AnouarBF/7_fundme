// SPDX-LIcense-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract Fund is Script {
    uint constant FUND_VALUE = 1 ether;

    function fundme_fund(address recentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(recentDeployment)).fund{value: FUND_VALUE}();
        vm.stopBroadcast();
        console.log("Funding successful with: ", FUND_VALUE);
    }

    function run() external {
        address recentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundme_fund(recentDeployment);
    }
}

contract Withdraw is Script {
    function withdrawFund(address recentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(recentDeployment)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance");
    }

    function run() external {
        address recentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFund(recentDeployment);
    }
}
