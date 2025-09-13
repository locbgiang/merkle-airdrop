// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from 'forge-std/Test.sol';
import {BagelToken} from '../../src/BagelToken.sol';
import {Deployment} from "../../script/Deployment.s.sol";

contract BagelTokenTest is Test {
    BagelToken token;
    address owner = makeAddr("owner");
    Deployment deployer = new Deployment();
    
    function setUp() public {
        vm.startPrank(owner);
        token = new BagelToken();
        vm.stopPrank();
    }

    function testMint() public {
        vm.startPrank(token.owner());
        token.mint(token.owner(), 100 ether);
        vm.stopPrank();
        assertEq(token.balanceOf(token.owner()), 100 ether);
    }

    function testDeploymentScript() public {
        BagelToken deployerToken = deployer.run();
        assertTrue(address(deployerToken) != address(0));
    }
}