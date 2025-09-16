// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {Script, console} from "forge-std/Script.sol";
// import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
// import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

// contract ClaimAirdrop is Script {

//     // the signature will change every time the airdrop contract is redeployed
//     bytes private SIGNATURE = hex;

//     function run() external {
//         address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
//             "MerkleAirdrop",
//             block.chainid
//         );
//         claimAirdrop(mostRecentlyDeployed);
//     }

//     function claimAirdrop (address airdrop) public {
//         vm.startBroadcast();
//         (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
//         console.log("Claiming Airdrop");
//         MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proof, v, r, s);
//         vm.stopBroadcast();
//         console.log("Claimed Airdrop");
//     }

//     function splitSignature (bytes memory sig) public pure returns(uint8 v, bytes32 r, bytes32 s) {
//         if (sig.length != 65) {
//             revert ClaimAirdropScript__InvalidSignatureLength();
//         }
//         assembly {
//             r := mload(add(sig, 32))
//             s := mload(add(sig, 64))
//             v := byte(0, mload(add(sig, 96)))
//         }
//     } 
// }