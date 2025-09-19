// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Fund, Withdraw} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract TestIntegration is Test {
    FundMe fundme;
    DeployFundMe deployer;
    uint private constant MINIMUM_USD = 1000;
    address immutable FUNDER = makeAddr("funder");
    uint constant INITIAL_BALANCE = 100 ether;
    uint immutable FUNDING_AMOUNT = 1 ether;

    function setUp() external {
        deployer = new DeployFundMe();
        fundme = deployer.run();
        vm.deal(FUNDER, INITIAL_BALANCE);
    }

    function test_fund_FundMe() external {
        uint ownerInitialBalance = fundme.owner().balance;
        uint contractInitialBalance = address(fundme).balance;

        vm.prank(FUNDER);
        fundme.fund{value: FUNDING_AMOUNT}();

        Withdraw withdrawing = new Withdraw();
        withdrawing.withdrawFund(address(fundme));

        assert(
            fundme.owner().balance ==
                FUNDING_AMOUNT + ownerInitialBalance + contractInitialBalance
        );
        assert(address(fundme).balance == 0);
    }
}
