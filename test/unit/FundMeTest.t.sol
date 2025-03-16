// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Fundme} from "../../src/Fundme.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";

contract FundmeTest is Test {
    Fundme fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.sendFund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        // fundMe = new Fundme(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundme deployFundme = new DeployFundme();
        fundMe = deployFundme.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSD() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        // assertEq(fundMe.getOwner(), makeAddr("deployer"));
        assertEq(fundMe.getOwner(), msg.sender); // beacuse us -> FundmeTest -> Fundme // so this contract is actually the owner here
    }

    function testDataFeedVersionAccuracy() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundfailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.sendFund();
    }

    function testFundupdatedFundeddataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwner() public funded {
        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(bytes4(keccak256("Not_Owner()")))
        );

        fundMe.withdrawFund();
    }

    function testWithdrawWithAsingleFunder() public funded {
        //arrange
        vm.txGasPrice(GAS_PRICE);
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();

        //Act

        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawFund();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsedinWei = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsedinWei);
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundmeBalance = address(fundMe).balance;
        assertEq(
            startingFundmeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        assertEq(endingFundmeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //arranage
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        vm.txGasPrice(GAS_PRICE);

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.sendFund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawFund();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsedinWei = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsedinWei);
        //assert
        //uint256 endingOwnerBalance = fundMe.getOwner().balance;
        //uint256 endingFundmeBalance = address(fundMe).balance;
        assert(
            startingFundmeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        assert(address(fundMe).balance == 0);
    }

    function testWithdrawFromMultipleFundersCheperWithdraw() public funded {
        //arranage
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        vm.txGasPrice(GAS_PRICE);

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.sendFund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsedinWei = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsedinWei);
        //assert
        //uint256 endingOwnerBalance = fundMe.getOwner().balance;
        //uint256 endingFundmeBalance = address(fundMe).balance;
        assert(
            startingFundmeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        assert(address(fundMe).balance == 0);
    }
}
