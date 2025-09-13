// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract MerkleAirdrop is EIP712 {
    error MerkleAirdrop__AlreadyClaimed();
    error MerkelAirdrop__InvalidSignature();

    mapping(address => bool) s_hasClaimed;

    constructor () EIP712("Merkle Airdrop", "1.0.0") {
    }

    /**
     * This function allows a user to claim their airdrop allocation.
     * @param account account of the claimer
     * @param amount amount to claim
     * @param merkleProof the merkle proof to verify the claim
     * @param v ECDSA signature
     * @param r ECDSA signature
     * @param s ECDSA signature
     */
    function claim (
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        // check if claimed already
        if (s_hasClaimed[account]){
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // verify signature
        if (!_isValidSignature()) {
            revert MerkelAirdrop__InvalidSignature();
        }

        // verify merkle proof
        // mark as claimed
        s_hasClaimed[account] = true;

        // transfer the token
    }

    /**
     * This function creates a standardized message hash for EIP-712 signature verification
     * Here is how it works:
     * The getMessageHash function generates a unique hash that represent a claim request
     * for a specific account and amount.
     * This hash is used for cryptographic verification
     * to make sure only authorized user can claim their drop
     * @param account 
     * @param amount 
     */
    function getMessageHash(address account, uint256 amount) public {
        
    }

    ///////////////////////////////////////////////////////////////////
    // INTERNAL ///////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////

    /**
     * This function verify whether the recovered signer 
     * is the expected signer/the account to aidrop token for
     */
    function _isValidSignature(
        address signer,
        bytes32 digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) 
        internal
        pure
        returns (bool)
    {
        // could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        (
            address actualSigner, 
            /* ECDSA.RecoverError recoverError */,
            /* bytes32 signatureLength */
        ) = ECDSA.tryRecover(digest, _v, _r, _s);
        return (actualSigner == signer);
    }
}