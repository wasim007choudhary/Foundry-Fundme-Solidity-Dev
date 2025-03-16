// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Fundme} from "../src/Fundme.sol";
import {HelperConfig} from "./helperconfig.s.sol";

contract DeployFundme is Script {
    function run() external returns (Fundme) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        Fundme fundMe = new Fundme(ethUsdPriceFeed);

        vm.stopBroadcast();
        return fundMe;
    }
}
