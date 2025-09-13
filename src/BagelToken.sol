// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Importing ERC20 standard implementation from OpenZeppelin library.
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Ownable provides basic access control mechanism.
// It establishes an 'owner' role that can be assigned to an account.
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BagelToken
 * @author Loc Giang
 * @notice a simple ERC20 token
 */
contract BagelToken is ERC20, Ownable {
    // sets the token name and symbol
    // set the deployer as the owner
    constructor() ERC20("BagelToken", "BT") Ownable(msg.sender) {}

    // external function that calls the internal _mint function
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
