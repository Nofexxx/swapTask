// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Swap} from "src/swap.sol";
import {ISwap} from "src/interfaces/ISwap.sol";

contract WithdrawTest is Test {
    Swap public mySwap;

    address public owner;
    
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_URL");
        vm.createSelectFork(rpcUrl);

        mySwap = new Swap(router);

        owner = makeAddr("owner");

        mySwap.transferOwnership(owner);

        vm.deal(address(mySwap), 1 ether);
    }

    function test_successWithdraw() public {
        uint256 balanceBefore = owner.balance;

        vm.prank(owner);
        mySwap.withdraw();

        uint256 balanceAfter = owner.balance;

        assertGt(balanceAfter, balanceBefore);
    }

    function test_revertIf_InsufficientBalance() public {
        vm.startPrank(owner);

        mySwap.withdraw();
        vm.expectRevert(ISwap.InsufficientBalance.selector);
        mySwap.withdraw();

        vm.stopPrank();
    }
}