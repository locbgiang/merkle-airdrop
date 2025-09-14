// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

// Merkle proof generator script
// To user:
// 1. Run `forge script script/GenerateInput.s.sol` to generate the input file
// 2. run `froge script script/Merkle.s.sol
// 3. the output file will be generated in /script/target/output.json

/**
 * @title MakeMerkle
 * @author Loc Giang
 * 
 * Original Work by:
 * @author kootsZhin
 * @notice https://github.com/dmfxyz/murky
 */
contract MakeMerkle is Script {
    // @dev read the input file and generate the merkleproof, then write the output file
    function run () public {

    }
}