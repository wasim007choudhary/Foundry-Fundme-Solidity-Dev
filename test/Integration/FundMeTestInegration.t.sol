// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Fundme} from "../../src/Fundme.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";
import {Fundfundme, Withdrawfundme} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    Fundme fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundme deploy = new DeployFundme();
        fundMe = deploy.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        Fundfundme fundFundme = new Fundfundme();
        fundFundme.fundFundme(address(fundMe));

        Withdrawfundme withdrawFundme = new Withdrawfundme();
        withdrawFundme.withdrawFundme(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
