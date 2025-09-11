// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from 'forge-std/Script.sol';
import {BagelToken} from '../src/BagelToken.sol';

contract Deployment is Script {
    function run() external { 
        vm.startBroadcast();
        new BagelToken();
        vm.stopBroadcast();
    }
}
