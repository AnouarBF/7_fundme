// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__Bad_price();
error FundMe__Bad_Decimals_One();
error FundMe__Bad_Decimals_two();
error HopeItReverts();

library ConversionRate {
    // this function gets the price of eth in terms of usd using chainlink aggregator
    function getPrice(
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint) {
        (, int price, , , ) = _priceFeed.latestRoundData();
        if (price <= 0) revert FundMe__Bad_price();
        uint8 decimals = _priceFeed.decimals();
        // if (decimals != 8) revert HopeItReverts(); /////////////////////
        uint roundedPrice_18 = uint(price) * (10 ** (18 - decimals));
        return roundedPrice_18;
    }

    // This function returns the conversion rate for the funded amount of eth in usd
    function getConversion(
        uint _amount,
        AggregatorV3Interface _priceFeed
    ) public view returns (uint) {
        uint price = getPrice(_priceFeed);
        uint amountInUsd = (_amount * price) / 1e18;

        return amountInUsd;
    }
}
