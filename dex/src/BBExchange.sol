// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BBToken} from "./BBToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BBExchange is Ownable {
    string public constant EXCHANGE_NAME = "Bull and Bear Exchange";

    BBToken public token;

    // Liquidity pool for the exchange
    uint256 private tokenReserves = 0;
    uint256 private ethReserves = 0;

    mapping(address => uint256) private lps;

    // Needed for looping through the keys of the lps mapping
    address[] private lpProviders;

    // liquidity rewards
    uint256 private swapFeeNumerator = 3;
    uint256 private swapFeeDenominator = 100;

    // Constant: x * y = k
    uint256 private k;

    constructor(address bbTokenAddr, address initialOwner) Ownable(initialOwner) {
        token = BBToken(bbTokenAddr);
    }

    // Function createPool: Initializes a liquidity pool between your Token and ETH.
    // ETH will be sent to pool in this transaction as msg.value
    // amountTokens specifies the amount of tokens to transfer from the liquidity provider.
    // Sets up the initial exchange rate for the pool by setting amount of token and amount of ETH.
    function createPool(uint256 amountTokens) external payable onlyOwner {
        // This function is already implemented for you; no changes needed.

        // require pool does not yet exist:
        require(tokenReserves == 0, "Token reserves was not 0");
        require(ethReserves == 0, "ETH reserves was not 0.");

        // require nonzero values were sent
        require(msg.value > 0, "Need eth to create pool.");
        uint256 tokenSupply = token.balanceOf(msg.sender);
        require(amountTokens <= tokenSupply, "Not have enough tokens to create the pool");
        require(amountTokens > 0, "Need tokens to create pool.");

        token.transferFrom(msg.sender, address(this), amountTokens);
        tokenReserves = token.balanceOf(address(this));
        ethReserves = msg.value;
        k = tokenReserves * ethReserves;
    }

    // Function removeLP: removes a liquidity provider from the list.
    // This function also removes the gap left over from simply running "delete".
    function removeLP(uint256 index) private {
        require(index < lpProviders.length, "specified index is larger than the number of lps");
        lpProviders[index] = lpProviders[lpProviders.length - 1];
        lpProviders.pop();
    }

    // Function getSwapFee: Returns the current swap fee ratio to the client.
    function getSwapFee() public view returns (uint256, uint256) {
        return (swapFeeNumerator, swapFeeDenominator);
    }

    // ============================================================
    //                    FUNCTIONS TO IMPLEMENT
    // ============================================================

    /* ========================= Liquidity Provider Functions =========================  */

    // Function addLiquidity: Adds liquidity given a supply of ETH (sent to the contract as msg.value).
    // You can change the inputs, or the scope of your function, as needed.
    function addLiquidity(uint256 maxExchangeRate, uint256 minExchangeRate) external payable {
        /**
         * TODO: Implement this function ******
         */
    }

    // Function removeLiquidity: Removes liquidity given the desired amount of ETH to remove.
    // You can change the inputs, or the scope of your function, as needed.
    function removeLiquidity(uint256 amountETH, uint256 maxExchangeRate, uint256 minExchangeRate) public payable {
        /**
         * TODO: Implement this function ******
         */
    }

    // Function removeAllLiquidity: Removes all liquidity that msg.sender is entitled to withdraw
    // You can change the inputs, or the scope of your function, as needed.
    function removeAllLiquidity(uint256 maxExchangeRate, uint256 minExchangeRate) external payable {
        /**
         * TODO: Implement this function ******
         */
    }
    /**
     *  Define additional functions for liquidity fees here as needed **
     */

    /* ========================= Swap Functions =========================  */

    // Function swapTokensForETH: Swaps your token with ETH
    // You can change the inputs, or the scope of your function, as needed.
    function swapTokensForETH(uint256 tokenAmount, uint256 maxExchangeRate) external payable {
        require(tokenAmount > 0, "Need tokens to swap");
        require(token.balanceOf(msg.sender) >= tokenAmount, "Not enough tokens");

        uint256 ethAmount = getEthAmount(tokenAmount);
        uint256 actualExchangeRate = (ethAmount * 1e18) / tokenAmount; // assuming 18 decimal places for ETH
        require(actualExchangeRate <= maxExchangeRate, "Exchange rate too high");

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), tokenAmount);

        // Update reserves and send ETH to user
        tokenReserves += tokenAmount;
        ethReserves -= ethAmount;

        // Transfer ETH to user
        payable(msg.sender).transfer(ethAmount);
    }

    // Function swapETHForTokens: Swaps ETH for your tokens
    // ETH is sent to contract as msg.value
    // You can change the inputs, or the scope of your function, as needed.
    function swapETHForTokens(uint256 maxExchangeRate) external payable {
        uint256 ethAmount = msg.value;
        require(ethAmount > 0, "Need ETH to swap");

        uint256 tokenAmount = getTokenAmount(ethAmount);
        uint256 actualExchangeRate = (tokenAmount * 1e18) / ethAmount; // assuming 18 decimal places for tokens
        require(actualExchangeRate <= maxExchangeRate, "Exchange rate too high");

        // Update reserves and send tokens to user
        ethReserves += ethAmount;
        tokenReserves -= tokenAmount;

        // Transfer Tokens to user
        token.transfer(msg.sender, tokenAmount);
    }

    function getEthAmount(uint256 tokenAmount) private view returns (uint256) {
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(tokenReserves > 0 && ethReserves > 0, "Invalid reserves");

        // Calculate ETH received without the fee
        uint256 ethReceived = (tokenAmount * ethReserves) / (tokenReserves + tokenAmount);

        // Calculate the fee on the ETH amount
        uint256 fee = (ethReceived * swapFeeNumerator) / swapFeeDenominator;
        ethReceived -= fee;

        require(ethReceived <= ethReserves, "Not enough ETH in reserves");
        return ethReceived;
    }

    function getTokenAmount(uint256 ethAmount) private view returns (uint256) {
        require(ethAmount > 0, "ETH amount must be greater than zero");
        require(tokenReserves > 0 && ethReserves > 0, "Invalid reserves");

        // Calculate Tokens received without the fee
        uint256 tokensReceived = (ethAmount * tokenReserves) / (ethReserves + ethAmount);

        // Calculate the fee on the token amount
        uint256 fee = (tokensReceived * swapFeeNumerator) / swapFeeDenominator;
        tokensReceived -= fee;

        require(tokensReceived <= tokenReserves, "Not enough Tokens in reserves");
        return tokensReceived;
    }
}
