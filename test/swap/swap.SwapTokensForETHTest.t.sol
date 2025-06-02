// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Swap} from "src/swap.sol";
import {ISwap} from "src/interfaces/ISwap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract swapTokensForETHTest is Test {
    Swap public mySwap;
    IERC20 tokenIn;

    uint256 public amountOutMin = 1 * 10**6;
    uint256 public amountIn = 100 * 10**6; // 100 tokenIn

    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public whale = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public user; 

    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_URL");
        vm.createSelectFork(rpcUrl);

        mySwap = new Swap(router);
        user = makeAddr("user");
        
        tokenIn = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        
        deal(whale, 1 ether);
        vm.prank(whale);
        tokenIn.transfer(user, amountIn);
    }

    function test_revertIf_tokenInZeroAddress() public{
        IERC20 tokenInZeroAddress = IERC20(address(0));

        vm.expectRevert(ISwap.ZeroAddress.selector);
        mySwap.swapTokensForETH(address(tokenInZeroAddress), amountIn, amountOutMin);
    }

    function test_revertIf_InvalidAmountIn() public {
        uint256 invalidAmountIn = 0;

        vm.startPrank(user);

        tokenIn.approve(address(mySwap), amountIn);

        vm.expectRevert(ISwap.InvalidAmountIn.selector);
        mySwap.swapTokensForETH(address(tokenIn), invalidAmountIn, amountOutMin);

        vm.stopPrank();
    }

    function test_successSwapTokensForETH() public {
        vm.startPrank(user);

        tokenIn.approve(address(mySwap), amountIn);

        uint256 ethBefore = user.balance;

        mySwap.swapTokensForETH(address(tokenIn), amountIn, amountOutMin);

        uint256 ethBalance = user.balance;

        assertGt(ethBalance, ethBefore);

        vm.stopPrank();
    }   
}