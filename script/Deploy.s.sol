// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/swap.sol";

contract DeployScript is Script {
    Swap public mySwap;

    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function run() external {
        vm.startBroadcast();

        mySwap = new Swap(router);

        vm.stopBroadcast();
    }
}