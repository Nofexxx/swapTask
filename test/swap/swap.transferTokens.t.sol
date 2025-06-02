// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Swap} from "src/swap.sol";
import {ISwap} from "src/interfaces/ISwap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract transferTokensTest is Test{
    Swap public mySwap;
    IERC20 tokenIn;

    uint256 amount = 100 * 10**6;

    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public whale = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public receiver;
    address public owner;



    function setUp() public {
        string memory alchemyKey = vm.envString("ALCHEMY_PRIVATE_KEY");
        string memory url = string.concat("https://eth-mainnet.g.alchemy.com/v2/", alchemyKey);
        vm.createSelectFork(url);

        mySwap = new Swap(router);
        owner = makeAddr("owner");
        receiver = makeAddr("receiver");
        mySwap.transferOwnership(owner);
        
        tokenIn = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        deal(whale, 1 ether);
        vm.prank(whale);
        tokenIn.transfer(owner, amount);
    }

    function test_transferTokensSuccess() public {
        uint256 wantToTransfer = 90 * 10 ** 6;

        vm.startPrank(owner);

        tokenIn.transfer(address(mySwap), wantToTransfer);
        mySwap.transferTokens(address(tokenIn), receiver, wantToTransfer);
        
        vm.stopPrank();

        uint256 receiverBalance = tokenIn.balanceOf(receiver);

        assertEq(receiverBalance, wantToTransfer);
    }

    function test_revertIf_InsufficientBalance() public {
        uint256 wantToTransfer = 200 * 10 ** 6;

        vm.startPrank(owner);

        tokenIn.transfer(address(mySwap), tokenIn.balanceOf(owner));
        vm.expectRevert(ISwap.InsufficientBalance.selector);
        mySwap.transferTokens(address(tokenIn), receiver, wantToTransfer);

        vm.stopPrank();
    }
}