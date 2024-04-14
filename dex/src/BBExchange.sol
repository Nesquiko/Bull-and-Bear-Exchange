// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BBToken} from "./BBToken.sol";
import {BBLibrary} from "./BBLibrary.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BBExchange is Ownable {
    string public constant EXCHANGE_NAME = "Bull and Bear Exchange";
    uint256 public constant MIN_LIQUIDITY = 1;

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
    function swapTokensForETH(uint256 tokenAmount) external {
        require(tokenAmount > 0, "Need tokens to swap");
        require(token.balanceOf(msg.sender) >= tokenAmount, "Not enough tokens");
        require(token.allowance(msg.sender, address(this)) >= tokenAmount, "Not enough token allowed for transfer");

        (uint256 weiAmount, uint256 withFee) = getWeiAmount(tokenAmount);
        require(weiReserves - weiAmount > MIN_LIQUIDITY, "Not enough liquidity");

        token.transferFrom(msg.sender, address(this), tokenAmount);

        tokenReserves += tokenAmount;
        weiReserves -= withFee;
        k = tokenReserves * weiReserves;

        (bool succes,) = payable(msg.sender).call{value: withFee}("");
        require(succes, "Transfer failed");
    }

    /// @notice Swaps eth for tokens
    /// @dev msg.value is how many wei the sender is swapping
    function swapETHForTokens() external payable {
        uint256 ethAmount = msg.value;
        require(ethAmount > 0, "Need ETH to swap");

        (uint256 tokenAmount, uint256 withFee) = getTokenAmount(ethAmount);
        require(tokenReserves - tokenAmount > MIN_LIQUIDITY, "Not enough liquidity");

        weiReserves += ethAmount;
        tokenReserves -= withFee;
        k = tokenReserves * weiReserves;

        token.transfer(msg.sender, withFee);
    }

    /// @param tokenAmount amount of token to be converted
    /// @return weiAmount value of tokenAmount in wei at current exchange rate
    /// @return withFee value of tokenAmount in wei at current exchange rate with fee accounted for
    function getWeiAmount(uint256 tokenAmount) public view returns (uint256 weiAmount, uint256 withFee) {
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(tokenReserves > 0 && weiReserves > 0, "Invalid reserves");

        return (
            BBLibrary.calculateAmountOut(tokenAmount, tokenReserves, weiReserves),
            BBLibrary.calculateAmountOutWithFee(
                tokenAmount, tokenReserves, weiReserves, swapFeeNumerator, swapFeeDenominator
                )
        );
    }

    /// @param weiAmount amount of wei to be converted
    /// @return tokenAmount value of weiAmount in token at current exchange rate
    /// @return withFee value of weiAmount in token at current exchange rate with fee accounted for
    function getTokenAmount(uint256 weiAmount) public view returns (uint256 tokenAmount, uint256 withFee) {
        require(weiAmount > 0, "Wei amount must be greater than zero");
        require(tokenReserves > 0 && weiReserves > 0, "Invalid reserves");

        return (
            BBLibrary.calculateAmountOut(weiAmount, weiReserves, tokenReserves),
            BBLibrary.calculateAmountOutWithFee(
                weiAmount, weiReserves, tokenReserves, swapFeeNumerator, swapFeeDenominator
                )
        );
    }
}
