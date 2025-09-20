// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error ConversionRate__Bad_price();
error ConversionRate__ZeroAmount();
error ConversionRate__Stale_Price();
error ConversionRate__Stale_Round();

library ConversionRate {
    // this function gets the price of eth in terms of usd using chainlink aggregator
    function getPrice(
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint) {
        (
            uint80 roundId,
            int price,
            ,
            uint updatedAt,
            uint80 answeredInRound
        ) = _priceFeed.latestRoundData();
        if (price <= 0) revert ConversionRate__Bad_price();
        if (block.timestamp - updatedAt > 1 hours)
            revert ConversionRate__Stale_Price();
        if (answeredInRound < roundId) revert ConversionRate__Stale_Round();
        uint8 decimals = _priceFeed.decimals();
        uint roundedPrice_18 = uint(price) * (10 ** (18 - decimals));
        return roundedPrice_18;
    }

    // This function returns the conversion rate for the funded amount of eth in usd
    function getConversion(
        uint _amount,
        AggregatorV3Interface _priceFeed
    ) public view returns (uint) {
        if (_amount == 0) revert ConversionRate__ZeroAmount();
        uint price = getPrice(_priceFeed);
        uint amountInUsd = (_amount * price) / 1e18;

        return amountInUsd;
    }
}
