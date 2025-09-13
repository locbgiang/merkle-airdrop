// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop is EIP712 {
    // library attachement 
    // adds ECDSA cryptographic functions directly to the bytes32 type
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    error MerkleAirdrop__AlreadyClaimed();
    error MerkelAirdrop__InvalidSignature();
    error MerkleAirdrop__InvalidProof();

    // the token that will be use for airdropping
    // data from constructor
    IERC20 private immutable i_airdropToken;

    // i_merkleRoot is a hash that has the property to prove whether any other hash belongs to its tree
    // like having a compressed list that can verify membership without storing the actual list
    // mapping(address => uint256) allowedClaims; would be expensive 
    // data from constructor
    bytes32 private immutable i_merkleRoot;

    // to keep track of who has claimed the airdrop already
    mapping(address => bool) s_hasClaimed;

    // this is a unique identifier for EIP-712 
    // this ensures that the signatures are tied to a specific data structure format
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    event Claimed(address account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("Merkle Airdrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /**
     * This function allows a user to claim their airdrop allocation.
     * Several checks are in place to make sure there are no
     * 1. double claiming
     * 2. 
     * @param account account of the claimer
     * @param amount amount to claim
     * @param merkleProof the merkle proof to verify the claim
     * @param v ECDSA signature
     * @param r ECDSA signature
     * @param s ECDSA signature
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        // check if claimed already
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // verify signature
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkelAirdrop__InvalidSignature();
        }

        // verify account/amount is part of the merkle tree
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // mark as claimed
        s_hasClaimed[account] = true;
        emit Claimed(account, amount);

        // transfer the token
        i_airdropToken.safeTransfer(account, amount);
    }

    /**
     * This function creates a standardized message hash for EIP-712 signature verification
     * Here is how it works:
     * The getMessageHash function generates a unique hash that represent a claim request
     * for a specific account and amount.
     * This hash is used for cryptographic verification
     * to make the hash is human readable
     * @param account the account of the message hash
     * @param amount the amount of the message hash
     */
    function getMessageHash(address account, uint256 amount) public view returns(bytes32){
        // _hashTypedDataV4 is a function from OpenZeppelin's EIP-712 contract
        // it creates the final hash used for EIP-712 signature verification
        return _hashTypedDataV4(
            // hashes the encoded bytes into a fixed 32-byte hash
            // creates a deterministic output (same input = same hash)
            keccak256(
                // abi.encode converts data into bytes
                // packs multiple values into a single byte array
                abi.encode(
                    MESSAGE_TYPEHASH,       // tye indetifier, prevent signature replay attacks
                    AirdropClaim({          // the actual data
                        account: account,
                        amount: amount
                    })
                )
            )
        );
    } 

    /////////////////////////////////////////////////////////
    // View and Pure ////////////////////////////////////////
    /////////////////////////////////////////////////////////

    function getMerkleRoot () external view returns(bytes32) {
        return i_merkleRoot;
    }

    function getAirdropTOken() external view returns(IERC20) {
        return i_airdropToken;
    }
    
    
    ///////////////////////////////////////////////////////////////////
    // INTERNAL ///////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////

    /**
     * This function verify whether the recovered signer
     * is the expected signer/the account to aidrop token for
     * @param signer the address of the signer
     * @param digest the message hash from getMessageHash
     * v, r, s - proves the account holder actually sign the message hash
     */
    function _isValidSignature(address signer, bytes32 digest, uint8 _v, bytes32 _r, bytes32 _s)
        internal
        pure
        returns (bool)
    {
        // could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        (
            address actualSigner,
            /* ECDSA.RecoverError recoverError */
            ,
            /* bytes32 signatureLength */
        ) = ECDSA.tryRecover(digest, _v, _r, _s);
        return (actualSigner == signer);
    }
}
