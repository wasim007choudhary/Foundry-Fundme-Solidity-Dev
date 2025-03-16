// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConvertor} from "./priceConvertor.sol";

error Not_Enough_USD_Sent();
error Not_Owner();
error Withdraw_Failed();

contract Fundme {
    using PriceConvertor for uint256;
    //uint256 public constant  newF= 20;

    AggregatorV3Interface private s_dataFeed;

    uint256 public constant MINIMUM_USD = 5e18; //or 5 * 10 ** 18//which is 5 dollars
    address[] private s_funders;
    //0x694AA1769357215DE4FAC081bf1f309aDC325306;
    mapping(address sender => uint256 amountFundedBysender)
        private s_AddressToAmountFunded;
    address private immutable i_owner;

    modifier Onlyowner() {
        if (msg.sender != i_owner) {
            revert Not_Owner();
        }
        _;
    }

    constructor(address dataFeed) {
        s_dataFeed = AggregatorV3Interface(dataFeed);
        i_owner = msg.sender;
    }

    receive() external payable {
        sendFund();
    }

    function sendFund() public payable {
        if (msg.value.getConversionRate(s_dataFeed) < MINIMUM_USD) {
            revert Not_Enough_USD_Sent();
        } else {
            s_funders.push(msg.sender);

            s_AddressToAmountFunded[msg.sender] += msg.value;
        }
    }

    function withdrawFund() public Onlyowner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool call_Success /* */, ) = i_owner.call{
            value: address(this).balance
        }("");
        if (!call_Success) {
            revert Withdraw_Failed();
        }
    }

    function cheaperWithdraw() public Onlyowner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool call_Success /* */, ) = i_owner.call{
            value: address(this).balance
        }("");
        if (!call_Success) {
            revert Withdraw_Failed();
        }
    }

    function getVersion() public view returns (uint256) {
        return s_dataFeed.version();
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    fallback() external payable {
        sendFund();
    }

    function getFunder(uint256 i) external view returns (address) {
        return s_funders[i];
    }

    function getAddressToAmountFunded(
        address funderAddress
    ) external view returns (uint256) {
        return s_AddressToAmountFunded[funderAddress];
    }

    function getDataFeed() public view returns (AggregatorV3Interface) {
        return s_dataFeed;
    }
}
