// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__Bad_price();
library ConversionRate {
    // this function gets the price of eth in terms of usd using chainlink aggregator
    function getPrice(
        AggregatorV3Interface _priceFeed
    ) public view returns (uint) {
        (, int price, , , ) = _priceFeed.latestRoundData();
        if (price <= 0) revert FundMe__Bad_price();
        // Fix the unit
        uint8 DECIMAL = 18 - _priceFeed.decimals();
        int roundedNumber = price * int((10 ** DECIMAL));
        return uint(roundedNumber);
    }

    // This function returns the conversion rate for the funded amount of eth in usd
    function getConversion(
        uint _amount,
        AggregatorV3Interface _priceFeed
    ) public view returns (uint) {
        uint amountInUsd = (_amount * getPrice(_priceFeed)) / 1e18;
        return amountInUsd / 1e18;
    }
}
