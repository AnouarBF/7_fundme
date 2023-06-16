// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint constant SENT_AMOUNT = 0.1 ether;
    address SENDER = makeAddr("user");
    uint constant STARTING_BALANCE = 10 ether;
    uint constant GAS_PRICE = 1;

    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(SENDER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testUpdatesFundedDataStructure() public {
        vm.prank(SENDER);
        fundMe.fund{value: SENT_AMOUNT}();

        assertEq(fundMe.getAddressToAmountFunded(SENDER), SENT_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(SENDER);
        fundMe.fund{value: SENT_AMOUNT}();

        assertEq(fundMe.getFunder(0), SENDER);
    }

    modifier funded() {
        vm.prank(SENDER);
        fundMe.fund{value: SENT_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(SENDER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        // Act
        // uint gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint gasEnd = gasleft();
        // uint gasUsed = (gasStart - gasEnd) * tx.gasPrice;
        // console.log(gasUsed);

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), SENT_AMOUNT);
            fundMe.fund{value: SENT_AMOUNT}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
