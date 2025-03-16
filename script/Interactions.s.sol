// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Fundme} from "../src/Fundme.sol";

contract Fundfundme is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundme(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Fundme(payable(mostRecentlyDeployed)).sendFund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded Fundme with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Fundme",
            block.chainid
        );

        fundFundme(mostRecentlyDeployed);
    }
}

contract Withdrawfundme is Script {
    function withdrawFundme(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Fundme(payable(mostRecentlyDeployed)).cheaperWithdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Fundme",
            block.chainid
        );

        withdrawFundme(mostRecentlyDeployed);
    }
}
