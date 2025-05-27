// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {console} from "forge-std/console.sol";
import {ISwap} from "./interfaces/ISwap.sol";

contract Swap is ISwap, Ownable {
    IUniswapV2Router02 public immutable router;
    address public immutable WETH;

    constructor(address _router, address _WETH) Ownable(msg.sender) {
        WETH = _WETH;
        router = IUniswapV2Router02(_router);
    } 

    function swapETHforTokens(address tokenOut, uint256 amountOutMin) external payable{
        if(WETH == address(0) || tokenOut == address(0)) revert ZeroAddress();
        if(msg.value == 0) revert InsufficientBalance();

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = tokenOut;


        router.swapETHForExactTokens{value: msg.value}(
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        emit SwapETHForTokens(msg.sender, tokenOut, msg.value, amountOutMin);        
    }

    function swapTokensForETH(address tokenIn, uint256 amountIn, uint256 amountOutMin) external {
        if(WETH == address(0) || tokenIn == address(0)) revert ZeroAddress();

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = WETH;

        router.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        emit SwapTokensForETH(msg.sender, tokenIn, amountIn, amountOutMin);
    }

    function swapTokensForToken(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin) external {
        if(WETH == address(0) || tokenIn == address(0)) revert ZeroAddress();

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        emit SwapTokensForTokens(msg.sender, tokenIn, tokenOut, amountIn, amountOutMin);
    }

    function transferETH(address to, uint256 amount) external onlyOwner{
        if(address(this).balance < amount) revert InsufficientBalance();
        (bool success, ) = to.call{value: amount}("");
        if(!success) revert WithdrawFailed();

        emit TransferedETH(to, amount);
    }

    function transferTokens(address token, address to, uint256 amount) external onlyOwner{
        if(IERC20(token).balanceOf(address(this)) < amount) revert InsufficientBalance();
        IERC20(token).transfer(to, amount);

        emit TransferedTokens(to, amount);
    }

    function withdraw() external onlyOwner {
        uint256 ETHbalance = address(this).balance;
        
        if(address(this).balance == 0) revert InsufficientBalance();
        (bool success, ) = owner().call{value: ETHbalance}("");
        if(!success) revert WithdrawFailed();

        emit Withdraw(msg.sender, address(this).balance);
    }    

    receive() external payable {}
  
}