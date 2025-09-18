// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ConversionRate} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error FundMe__Not_Sufficient_Fund();
error FundMe__FailedWithdrawal();
error FundMe__NoFundingYet();

contract FundMe is Ownable, ReentrancyGuard {
    using ConversionRate for uint;

    address private immutable i_owner;
    uint private constant MINIMUM_USD = 1000;
    address[] private s_funders;
    mapping(address => uint) private s_FunderAmount;
    mapping(address => bool) private s_hasFunded;

    AggregatorV3Interface s_priceFeed;

    constructor(address _priceFeed) Ownable(msg.sender) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    // Fund function that users should call and send some eth to in order to fund the contract
    function fund() public payable {
        uint fundedAmount_usd = (msg.value).getConversion(s_priceFeed) / 1e18;
        address funder = msg.sender;
        if (fundedAmount_usd < MINIMUM_USD) {
            revert FundMe__Not_Sufficient_Fund();
        }
        if (s_hasFunded[funder]) {
            s_FunderAmount[funder] += fundedAmount_usd;
        } else {
            s_funders.push(funder);
            s_FunderAmount[funder] = fundedAmount_usd;
            s_hasFunded[funder] = true;
        }
    }

    // Withdraw function that the owner of the contract should call in order to withdraw all the funds from the contract to his address
    function withdraw() external onlyOwner nonReentrant {
        if (address(this).balance == 0) revert FundMe__NoFundingYet();
        address[] memory funders = s_funders;
        uint length = funders.length;
        for (uint index; index < length; index++) {
            address funder = funders[index];
            s_FunderAmount[funder] = 0;
            s_hasFunded[funder] = false;
        }
        (bool success, ) = payable(i_owner).call{value: address(this).balance}(
            ""
        );
        if (!success) revert FundMe__FailedWithdrawal();
        s_funders = new address[](0);
    }

    // Getters
    function get_minimumUsd() external pure returns (uint) {
        return MINIMUM_USD;
    }

    function hasFunded(address funder) external view returns (bool) {
        return s_hasFunded[funder];
    }

    function amountFunded(address funder) external view returns (uint) {
        return s_FunderAmount[funder];
    }

    function getFunder(uint index) external view returns (address) {
        return s_funders[index];
    }

    function get_fundersNumber() external view returns (uint) {
        return s_funders.length;
    }

    function get_PriceFeed() external view returns (address) {
        return address(s_priceFeed);
    }
}
