// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {Merkle} from "murky/src/Merkle.sol";
// ScriptHelper is a utility contract from Murky library that provides helper functions
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

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
contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string; // enables use to use the json cheatcodes for strings

    Merkle private m = new Merkle();

    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    // get the absolute path
    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath));
    // gets the merkle tree leaf types from json using forge standard lib cheatcode
    string[] private types = elements.readStringArray(".types"); 
    // ge the number of leaf nodes
    uint256 private count = elements.readUint(".count");

    // make three arrays the same size as the number of leaf nodes
    bytes32[] private leafs = new bytes32[](count);

    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    string private output;

    /**
     * @dev Returns the JSON path of the input file
     * output file output ".values.some-address.some-amount"
     */
    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    /**
     * 
     */
    function generateJsonEntries(
        string memory _inputs,
        string memory _proof,
        string memory _root,
        string memory _leaf
    )
        internal
        pure
        returns (string memory) 
    {
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );

        return result;
    }


    // @dev read the input file and generate the merkleproof, then write the output file
    function run () public {
        console.log("Generating Merkle Proof for %s", inputPath);

        for (uint256 i = 0; i < count; ++i) {
            // stringified data (address and string both as strings)
            string[] memory input = new string[](types.length); 
            // actual data as bytes32
            bytes32[] memory data = new bytes32[](types.length);

            for (uint256 j = 0; j < types.length; j++) {
                if (compareStrings(types[j], "address")) {
                    address value = elements.readAddress(getValuesByIndex(i, j));
                    data[j] = bytes32(uint256(uint160(value)));
                    input[j] = vm.toString(value);
                } else if (compareStrings(types[j], "uint")) {
                    uint256 value = vm.parseUint(elements.readString(getValuesByIndex(i, j)));
                    data[j] = bytes32(value);
                    input[j] = vm.toString(value);
                }
            }

            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));

            inputs[i] = stringArrayToString(input);
        }

        for (uint256 i = 0; i < count; i++) {
            // get proof gets the nodes needed for the proof & stringify (from helper lib)
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            // get the root hash and stringify
            string memory root = vm.toString(m.getRoot(leafs));
            // get the specific leaf working on
            string memory leaf = vm.toString(leafs[i]);
            // get the stringified input (adress, amount)
            string memory input = inputs[i];

            // generate the Json output file (tree dump)
            outputs[i] = generateJsonEntries(input, proof, root, leaf);

        }

        // stringify the array of strings to a single string
        output = stringArrayToArrayString(outputs);

        // write to the output file the stringified output json (tree dump)
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console.log("DONE: The output is found at %s", outputPath);
    }
}