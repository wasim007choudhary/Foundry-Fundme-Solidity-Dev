// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    function getPrice(
        AggregatorV3Interface dataFeed
    ) internal view returns (uint256) {
        (, int256 answer, , , ) = dataFeed.latestRoundData();
        return uint256(answer * 1e18);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface dataFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(dataFeed);
        uint256 enteredEthinUsdPrice = (ethPrice * ethAmount) / 1e18;
        return enteredEthinUsdPrice;
    }
}
