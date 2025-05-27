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
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


    function setUp() public {
        owner = address(this);
        user = makeAddr("user");

        mySwap = new Swap(router, weth);

        vm.deal(address(mySwap), 1 ether);
    }

    function test_transferSuccsess() public {
        uint256 amount = 0.5 ether;
        uint256 balanceBefore = user.balance;

        mySwap.transferETH(user, amount);

        uint256 balanceAfter = user.balance;

        assertGt(balanceAfter, balanceBefore);
    }

    function test_revertIf_InsufficientBalance() public {
        uint256 amount = 2 ether;

        vm.expectRevert(ISwap.InsufficientBalance.selector);
        mySwap.transferETH(user, amount);
    }
}