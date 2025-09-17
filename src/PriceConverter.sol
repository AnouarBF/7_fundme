// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__Bad_price();
error FundMe__Bad_Decimals();
error HopeItReverts();

library ConversionRate {
    // this function gets the price of eth in terms of usd using chainlink aggregator
    function getPrice(
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint, uint) {
        (, int price, , , ) = _priceFeed.latestRoundData();
        if (price <= 0) revert FundMe__Bad_price();
        // Fix the unit
        uint DECIMAL = 18 - _priceFeed.decimals();
        uint TOTAL_DECIMAL = 10 ** DECIMAL;
        uint roundedNumber = uint(price) * TOTAL_DECIMAL;
        return (roundedNumber, TOTAL_DECIMAL);
    }

    // This function returns the conversion rate for the funded amount of eth in usd
    function getConversion(
        uint _amount,
        AggregatorV3Interface _priceFeed
    ) public view returns (uint) {
        (uint price, uint decimals) = getPrice(_priceFeed);

        if (decimals != 10) revert FundMe__Bad_Decimals();
        if (price < 1e18) revert FundMe__Bad_price();
        uint amountInUsd = (_amount * price) / 1e18;
        if (amountInUsd <= 0) revert HopeItReverts();

        return uint(amountInUsd / 1e18);
    }
}
