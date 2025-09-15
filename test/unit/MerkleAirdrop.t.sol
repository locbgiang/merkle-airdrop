// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";

/**
 * @title MerkleAirdropTest
 * @author Loc Giang
 * @notice This is the test for the MerkleAirdrop contract
 */
contract MerkleAirdropTest is Test {
    BagelToken token;
    MerkleAirdrop airdrop;

    address gasPayer;
    address user;
    uint256 userPrivKey;

    bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 amountToCollect = (25 * 1e18); // 25.00000
    uint256 amountToSend = amountToCollect * 4;

    bytes32 private constant proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a; 
    bytes32 private constant proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576; 
    bytes32[] public PROOF = [proofOne, proofTwo];


    function setUp () public {
        // deploy the BagelToken
        token = new BagelToken();
        // deploy the airdrop contract
        airdrop = new MerkleAirdrop(merkleRoot, token);
        // mint all of the bagel token to be airdrop
        token.mint(token.owner(), amountToSend);
        // transfer the total amount to the airdrop contract
        token.transfer(address(airdrop), amountToSend);
        // create a gas paying user
        gasPayer = makeAddr("gasPayer");
        // create the user
        (user, userPrivKey) =  makeAddrAndKey("user");
    }  

    /**
     * @param privKey is the private key of the user
     * @param account is the address of the acccount
     */
    function signMessage(uint256 privKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessage = airdrop.getMessageHash(account, amountToCollect);
        (v, r, s) = vm.sign(privKey, hashedMessage);
    }

    /**
     * 
     */
    function testUserCanClaim() public {
        uint256 startingBalance;

        // get the signature of the user
        vm.prank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
        vm.stopPrank();

        // gasPayer claim the airdrop for the user, they also pay the gas
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("User balance after claim: ", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
        vm.stopPrank();
    }
}