// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

contract DeployScriptTest is Test {
    DeployScript myDeployScript;
    Swap deployedSwap;

    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_URL");
        vm.createSelectFork(rpcUrl);

        myDeployScript = new DeployScript();

        myDeployScript.run();
        deployedSwap = myDeployScript.mySwap();
    }

    function test_nonZeroAddress() public view { assert(address(deployedSwap) != address(0)); }

    function test_contractOwner() public view { assertEq(deployedSwap.owner(), address(msg.sender)); }

    function test_revertIf_ZeroAddressRouter() public {
        address zeroAddressRouter = address(0);
        
        vm.expectRevert(ISwap.ZeroAddress.selector);
        new Swap(zeroAddressRouter);
    }
}
