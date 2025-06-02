// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Swap} from "src/swap.sol";
import {ISwap} from "src/interfaces/ISwap.sol";

contract transferETHTest is Test {
    Swap public mySwap;

    address public owner;
    address public user;
    
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_URL");
        vm.createSelectFork(rpcUrl);

        owner = address(this);
        user = makeAddr("user");

        mySwap = new Swap(router);

        vm.deal(address(mySwap), 1 ether);
    }

    function test_revertIf_InsufficientBalance() public {
        uint256 amount = 2 ether;

        vm.expectRevert(ISwap.InsufficientBalance.selector);
        mySwap.transferETH(user, amount);
    }

    function test_revertIf_ZeroAmount() public {
        uint256 wrongAmount = 0 ether;

        vm.expectRevert(ISwap.ZeroAmount.selector);
        mySwap.transferETH(user, wrongAmount);
    }

    function test_transferSuccess() public {
        uint256 amount = 0.5 ether;
        uint256 balanceBefore = user.balance;

        mySwap.transferETH(user, amount);

        uint256 balanceAfter = user.balance;

        assertGt(balanceAfter, balanceBefore);
    }
}