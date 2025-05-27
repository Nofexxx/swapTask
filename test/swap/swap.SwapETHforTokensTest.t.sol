// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Swap} from "src/swap.sol";
import {ISwap} from "src/interfaces/ISwap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapETHforTokensTest is Test {
    Swap public mySwap;
    IERC20 tokenOut;

    uint256 public amountOutMin = 1 * 10**6;
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public user; 
    

    function setUp() public {
        string memory alchemyKey = vm.envString("ALCHEMY_PRIVATE_KEY");
        string memory url = string.concat("https://eth-mainnet.g.alchemy.com/v2/", alchemyKey);
        vm.createSelectFork(url);
        
        mySwap = new Swap(router, weth);
        user = makeAddr("user");
        tokenOut = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }

    function test_revertIf_InsufficientBalance() public{
        vm.expectRevert(ISwap.InsufficientBalance.selector);
        mySwap.swapETHforTokens(address(tokenOut), amountOutMin);
    }

    function test_revertIf_ZeroAddress() public{
        Swap zeroAddressSwap = new Swap(address(0), address(0));
        
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert(ISwap.ZeroAddress.selector);
        zeroAddressSwap.swapETHforTokens{value: 1 ether}(address(tokenOut), amountOutMin);
    }

    function test_swapETHforTokens() public {
        uint256 balanceBefore = tokenOut.balanceOf(user);

        vm.deal(user, 1 ether);
        vm.prank(user);
        mySwap.swapETHforTokens{value: 1 ether}(address(tokenOut), amountOutMin);
        
        assertEq(user.balance, 0);
        assertGt(tokenOut.balanceOf(user), balanceBefore);
    }
}