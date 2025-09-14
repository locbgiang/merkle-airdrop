// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";

contract MerkleAirdropTest is Test {
    BagelToken token;
    MerkleAirdrop airdrop;

    // bytes32 merkleRoot = 

    function setUp () public {
        token = new BagelToken();
        airdrop = new MerkleAirdrop(merkleRoot, token);
    }
}