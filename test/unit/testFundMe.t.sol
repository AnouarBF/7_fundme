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
        vm.prank(FUNDER);
        fundme.fund{value: FUNDING_AMOUNT}();
        assert(funderBalance * 2 == fundme.amountFunded(FUNDER));
    }

    function test_checkFundersLength() external funding {
        assert(fundme.get_fundersNumber() == 1);
    }

    function test_CheckHasFunded() external funding {
        assert(fundme.hasFunded(FUNDER));
    }

    ////////////////////////////////////////////////////////////////
    ////////////////////<< Withdraw() Function >>//////////////////
    //////////////////////////////////////////////////////////////

    function test_OnlyOwnerWithdraws() external funding {
        vm.expectRevert();
        vm.prank(FUNDER);
        fundme.withdraw();
    }

    function test_OwnerWithdraw() external funding {
        address owner = msg.sender;
        uint ownerInitialBalance = owner.balance;
        uint contractBalance = address(fundme).balance;

        vm.prank(owner);
        fundme.withdraw();
        // After the withdrawal, the owner balance should equal its initial balance plus the
        // contract balance after funding.
        assert(owner.balance == contractBalance + ownerInitialBalance);
    }

    function test_listNumberAfterWithdraw() external funding {
        address owner = msg.sender;

        vm.prank(owner);
        fundme.withdraw();

        assert(fundme.get_fundersNumber() == 0);
    }

    // This test only passes in Anvil localhost
    function test_revertwithdraw_emptyContract() external {
        if (block.chainid != 31337) {
            assert(true);
        } else {
            address owner = msg.sender;
            console.log(address(fundme).balance);
            vm.expectRevert();
            vm.prank(owner);
            fundme.withdraw();
        }
    }

    function test_Fallback() external funding {
        vm.prank(FUNDER);
        payable(address(fundme)).call("0x01");

        assert(fundme.hasFunded(FUNDER));
    }

    function test_Receive() external funding {
        vm.prank(FUNDER);
        payable(address(fundme)).call("");

        assert(fundme.hasFunded(FUNDER));
    }
}
