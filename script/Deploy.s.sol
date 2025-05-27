pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/swap.sol";

contract DeployScript is Script {
    Swap public mySwap;

    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function run() external {
        vm.startBroadcast();

        mySwap = new Swap(router, weth);

        vm.stopBroadcast();
    }
}