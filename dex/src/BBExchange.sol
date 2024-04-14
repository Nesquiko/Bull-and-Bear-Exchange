// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BBToken} from "./BBToken.sol";
import {BBLibrary} from "./BBLibrary.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BBExchange is Ownable {
    string public constant EXCHANGE_NAME = "Bull and Bear Exchange";

    BBToken public immutable token;

    uint256 public k; // Constant: x * y = k
    uint256 public tokenReserves = 0; // value on the x axis
    uint256 public weiReserves = 0; // value on the y axis

    mapping(address => uint256) private lps;
    // Needed for looping through the keys of the lps mapping
    address[] private lpProviders;

    // liquidity rewards
    uint256 private swapFeeNumerator = 3;
    uint256 private swapFeeDenominator = 100;

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
        require(weiReserves == 0, "ETH reserves was not 0.");

        // require nonzero values were sent
        require(msg.value > 0, "Need eth to create pool.");
        uint256 tokenSupply = token.balanceOf(msg.sender);
        require(amountTokens <= tokenSupply, "Not have enough tokens to create the pool");
        require(amountTokens > 0, "Need tokens to create pool.");

        token.transferFrom(msg.sender, address(this), amountTokens);
        tokenReserves = token.balanceOf(address(this));
        weiReserves = msg.value;
        k = tokenReserves * weiReserves;
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

    /// @notice Swaps tokens for ETH
    /// @param tokenAmount how many tokens the sender is swapping
    function swapTokensForETH(uint256 tokenAmount, uint256 maxExchangeRate) external payable {
        require(tokenAmount > 0, "Need tokens to swap");
        require(token.balanceOf(msg.sender) >= tokenAmount, "Not enough tokens");
        require(token.allowance(msg.sender, address(this)) >= tokenAmount, "Token transfer not allowed");

        uint256 ethAmount = getWeiAmount(tokenAmount);
        uint256 actualExchangeRate = (ethAmount * 1e18) / tokenAmount; // assuming 18 decimal places for ETH
        require(actualExchangeRate <= maxExchangeRate, "Exchange rate too high");

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), tokenAmount);

        // Update reserves and send ETH to user
        tokenReserves += tokenAmount;
        weiReserves -= ethAmount;

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
        weiReserves += ethAmount;
        tokenReserves -= tokenAmount;

        // Transfer Tokens to user
        token.transfer(msg.sender, tokenAmount);
    }

    /// @return Value of tokenAmount in wei at current exchange rate with fee accounted for
    function getWeiAmount(uint256 tokenAmount) public view returns (uint256) {
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(tokenReserves > 0 && weiReserves > 0, "Invalid reserves");

        return
            BBLibrary.calculateAmountOut(tokenAmount, tokenReserves, weiReserves, swapFeeNumerator, swapFeeDenominator);
    }

    function getTokenAmount(uint256 weiAmount) public view returns (uint256) {
        require(weiAmount > 0, "Wei amount must be greater than zero");
        require(tokenReserves > 0 && weiReserves > 0, "Invalid reserves");

        return BBLibrary.calculateAmountOut(weiAmount, weiReserves, tokenReserves, swapFeeNumerator, swapFeeDenominator);
    }
}
