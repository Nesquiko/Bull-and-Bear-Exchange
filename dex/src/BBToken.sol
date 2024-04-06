// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BBToken is Ownable, ERC20 {
    string private constant _symbol = "BBT"; // TODO: Give your token a symbol (all caps!)
    string private constant _name = "Bull and Bear Token"; // TODO: Give your token a name

    constructor(address initialOwner) Ownable(initialOwner) ERC20(_name, _symbol) {}

    // ============================================================
    //                    FUNCTIONS TO IMPLEMENT
    // ============================================================

    // Function _mint: Create more of your tokens.
    // You can change the inputs, or the scope of your function, as needed.
    // Do not remove the onlyOwner modifier!
    function mint(uint256 amount) public onlyOwner {
        /**
         * TODO: Implement this function ******
         */
    }

    // Function _disable_mint: Disable future minting of your token.
    // You can change the inputs, or the scope of your function, as needed.
    // Do not remove the onlyOwner modifier!
    function disable_mint() public onlyOwner {
        /**
         * TODO: Implement this function ******
         */
    }
}
