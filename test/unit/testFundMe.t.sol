// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";

contract TestFundMe is Test {
    FundMe fundme;
    DeployFundMe deployer;
    uint private constant MINIMUM_USD = 1000;
    address immutable FUNDER = makeAddr("funder");
    uint constant INITIAL_BALANCE = 1000 ether;
    uint immutable FUNDING_AMOUNT = 1 ether;

    function setUp() external {
        deployer = new DeployFundMe();
        fundme = deployer.run();
        vm.deal(FUNDER, INITIAL_BALANCE);
    }

    function test_correctPriceFeed() external view {
        assert(
            fundme.get_PriceFeed() == 0x34A1D3fff3958843C43aD80F30b94c510645C316
        );
    }

    function test_correctOwner() external view {
        address owner = fundme.owner();
        assert(owner == msg.sender);
    }

    function test_correctMinimumUSD() external view {
        uint minimum_usd = fundme.get_minimumUsd();
        assert(minimum_usd == MINIMUM_USD);
    }

    function test_emptyList() external view {
        assert(fundme.get_fundersNumber() == 0);
    }

    ////////////////////////////////////////////////////////////////
    //////////////////////<< fund() function >>////////////////////
    //////////////////////////////////////////////////////////////

    function test_revertUnsufficientFunding() external {
        vm.expectRevert();
        vm.prank(FUNDER);
        fundme.fund{value: 0.01 ether}();
    }

    modifier funding() {
        vm.prank(FUNDER);
        fundme.fund{value: FUNDING_AMOUNT}();
        _;
    }

    function test_successfulFunding() external {
        vm.prank(FUNDER);
        fundme.fund{value: FUNDING_AMOUNT}();
        assert(fundme.amountFunded(FUNDER) > 0);
    }

    function test_AlreadyFunded() external funding {
        uint funderBalance = fundme.amountFunded(FUNDER);
        console.log(funderBalance);
        vm.prank(FUNDER);
        fundme.fund{value: FUNDING_AMOUNT}();
        assert(funderBalance * 2 == fundme.amountFunded(FUNDER));
    }

    // function
}
