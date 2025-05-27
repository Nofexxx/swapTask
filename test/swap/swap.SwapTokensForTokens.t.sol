// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Swap} from "src/swap.sol";
import {ISwap} from "src/interfaces/ISwap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapTokensForTokensTest is Test {
    Swap public mySwap;
    IERC20 tokenIn;
    IERC20 tokenOut;

    uint256 amountIn = 100 * 10**6;
    uint256 amountOutMin = 1 * 10**6;

    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public whale = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public user;

    function setUp() public {
        string memory alchemyKey = vm.envString("ALCHEMY_PRIVATE_KEY");
        string memory url = string.concat("https://eth-mainnet.g.alchemy.com/v2/", alchemyKey);
        vm.createSelectFork(url);

        mySwap = new Swap(router, weth);
        user = makeAddr("user");
        
        tokenIn = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        tokenOut = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);

        deal(whale, 1 ether);
        vm.prank(whale);
        tokenIn.transfer(user, amountIn);
    }

    function test_swapTokensForTokens() public {
        uint256 balanceUsdcBefore = tokenIn.balanceOf(user);
        uint256 balanceUniswapBefore = tokenOut.balanceOf(user);

        vm.startPrank(user);
        
        tokenIn.approve(address(mySwap), amountIn);
        mySwap.swapTokensForToken(address(tokenIn), address(tokenOut), amountIn, amountOutMin);

        uint256 balanceUsdcAfter = tokenIn.balanceOf(user);
        uint256 balanceUniswapAfter = tokenOut.balanceOf(user);

        assertLt(balanceUsdcAfter, balanceUsdcBefore);
        assertGt(balanceUniswapAfter, balanceUniswapBefore);

        vm.stopPrank();
    }

    function test_revertIf_ZeroAddress() public {
        Swap zeroAddressSwap = new Swap(address(0), address(0));

        vm.startPrank(user);
        
        vm.expectRevert(ISwap.ZeroAddress.selector);
        zeroAddressSwap.swapTokensForToken(address(tokenIn),address(tokenOut), amountIn, amountOutMin);
        
        vm.stopPrank();
    }
}