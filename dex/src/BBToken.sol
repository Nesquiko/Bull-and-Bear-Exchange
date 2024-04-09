// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Simple ERC20 traded in Bull and Bear Exchange
/// @notice We argue that the two functions from assignment ("mint" and "disable_mint"),
///     which we have to implement, are useless and potentially an anti-pattern.
///     ERC20 implementation by OpenZeppelin is enough to implement a token,
///     with constant supply.
///     By pre-minting supply to the deployer of the token, we achieved a token
///     with constant supply (no new tokens can be minted as "_mint" in "ERC20"
///     is an internal function). Thus we have reduced the complexity of this
///     token implementation by removing "mint", "disable_mint" and even the
///     Ownable parent contract inheritance.
contract BBToken is ERC20 {
    /// @param supply Maximum supply of the Bull and Bear Token
    /// @notice minted to the sender of the transaction
    constructor(uint256 supply) ERC20("Bull and Bear Token", "BBT") {
        _mint(msg.sender, supply * 10 ** decimals());
    }
}
