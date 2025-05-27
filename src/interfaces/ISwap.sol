// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;


interface ISwap {
    event SwapETHForTokens(address indexed user, address tokenOut, uint256 amountIn, uint256 amountOut);
    event SwapTokensForETH(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);
    event SwapTokensForTokens(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event TransferedETH(address indexed to, uint256 amount);
    event TransferedTokens(address indexed to, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    error InsufficientBalance();
    error WithdrawFailed();
    error ZeroAddress();
    
    function swapETHforTokens(address tokenOut, uint256 amountOutMin) external payable;
    function swapTokensForETH(address tokenIn, uint256 amountIn, uint256 amountOutMin) external;
    function swapTokensForToken(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin) external;
    function transferETH(address to, uint256 amount) external;
    function transferTokens(address token, address to, uint256 amount) external;
    function withdraw() external;
}