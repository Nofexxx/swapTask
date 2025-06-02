// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

contract DeployScriptTest is Test {
    DeployScript myDeployScript;
    Swap deployedSwap;

    function setUp() public {
        string memory alchemyKey = vm.envString("ALCHEMY_PRIVATE_KEY");
        string memory url = string.concat("https://eth-mainnet.g.alchemy.com/v2/", alchemyKey);
        vm.createSelectFork(url);

        myDeployScript = new DeployScript();

        myDeployScript.run();
        deployedSwap = myDeployScript.mySwap();
    }

    function test_nonZeroAddress() public view { assert(address(deployedSwap) != address(0)); }

    function tets_contractOwner() public view { assertEq(deployedSwap.owner(), address(this)); }
}
