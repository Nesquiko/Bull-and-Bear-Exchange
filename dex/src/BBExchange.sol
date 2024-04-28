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
    uint256 public totalLiquidity;

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

        uint256 liquidity = weiReserves - MIN_LIQUIDITY; // locks MIN_LIQUIDITY
        lps[msg.sender] = liquidity;
        totalLiquidity += liquidity;
        lpProviders.push(msg.sender);
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

    /// @notice Adds liquidity given a supply of Eth and BBToken
    /// @dev msg.value amount of wei to be added to lp
    /// @param minLiquidity lower bound guard agains rate change
    /// @param maxTokenAmount upper bound guard agains rate change
    function addLiquidity(uint256 minLiquidity, uint256 maxTokenAmount) external payable {
        uint256 weiAmount = msg.value;
        require(weiAmount > 0, "No ETH provided");
        require(minLiquidity > 0, "minLiquidity can't be 0");
        require(maxTokenAmount > 0, "maxTokenAmount can't be 0");
        require(token.balanceOf(msg.sender) >= maxTokenAmount, "Not enough token balance");
        require(token.allowance(msg.sender, address(this)) >= maxTokenAmount, "Not enough token allowed for transfer");

        uint256 tokenAmount = BBLibrary.convertAtExchangeRate(weiAmount, weiReserves, tokenReserves);
        require(tokenAmount <= maxTokenAmount, "Rate change exceeds desired max token amount");
        // what portion of new liquidity was provided, can be calculated through wei,
        // or token, doesn't matter, but since only wei amount is exact
        // (tokenAmount can change based on time of tx processing), use wei instead.
        uint256 liquidityProvided = weiAmount * totalLiquidity / weiReserves;
        require(liquidityProvided >= minLiquidity, "Rate change exceeds desired minimum liquidity");

        if (lps[msg.sender] == 0) {
            lpProviders.push(msg.sender);
        }
        lps[msg.sender] += liquidityProvided;
        totalLiquidity += liquidityProvided;

        weiReserves += msg.value;
        tokenReserves += tokenAmount;
        k = weiReserves * tokenReserves;

        bool succes = token.transferFrom(msg.sender, address(this), tokenAmount);
        require(succes, "token transfer failed");
    }

    // Function removeLiquidity: Removes liquidity given the desired amount of ETH to remove.
    // You can change the inputs, or the scope of your function, as needed.
    function removeLiquidity(uint256 ethAmount, uint256 minWeiAmount, uint256 minTokenAmount) public payable {
        require(ethAmount > 0, "Amount must be greater than zero");
        uint256 liquidity = lps[msg.sender];
        require(liquidity > 0, "No liquidity found for sender");
        require(ethAmount <= liquidity, "Not enough liquidity");

        uint256 weiFee = (ethAmount * swapFeeNumerator * weiReserves) / (totalLiquidity * swapFeeDenominator);
        (uint256 tokenFees,) = getTokenAmount(weiFee);

        uint256 ethContribution = ((ethAmount * weiReserves) / totalLiquidity);
        require(ethContribution <= weiReserves - MIN_LIQUIDITY, "Insufficient wei liquidity");
        (uint256 tokenContribution,) = getTokenAmount(ethAmount);
        require(tokenContribution <= tokenReserves - MIN_LIQUIDITY, "Insufficient token liquidity");
        require(ethContribution >= minWeiAmount && tokenContribution >= minTokenAmount, "Too much slipage");

        ethContribution += weiFee;
        tokenContribution += tokenFees;

        // Update reserves
        weiReserves -= ethContribution;
        tokenReserves -= tokenContribution;
        k = weiReserves * tokenReserves;

        // Update liquidity records
        lps[msg.sender] -= ethAmount;
        totalLiquidity -= ethAmount;

        // Transfer ETH and tokens back to the liquidity provider
        (bool ethSuccess,) = msg.sender.call{value: ethContribution}("");
        require(ethSuccess, "Failed to send ETH");

        bool tokenSuccess = token.transfer(msg.sender, tokenContribution);
        require(tokenSuccess, "Failed to send tokens");
    }

    // Function removeAllLiquidity: Removes all liquidity that msg.sender is entitled to withdraw
    // You can change the inputs, or the scope of your function, as needed.
    function removeAllLiquidity(uint256 minWeiAmount, uint256 minTokenAmount) external payable {
        uint256 liquidity = lps[msg.sender];
        require(liquidity > 0, "No liquidity found for sender");

        uint256 ethAmount = (liquidity * weiReserves) / totalLiquidity;
        uint256 weiFee = (ethAmount * swapFeeNumerator * weiReserves) / (totalLiquidity * swapFeeDenominator);
        (uint256 tokenFees,) = getTokenAmount(weiFee);

        uint256 ethContribution = ((ethAmount * weiReserves) / totalLiquidity);
        require(ethContribution <= weiReserves - MIN_LIQUIDITY, "Insufficient wei liquidity");
        (uint256 tokenContribution,) = getTokenAmount(ethAmount);
        require(tokenContribution <= tokenReserves - MIN_LIQUIDITY, "Insufficient token liquidity");
        require(ethContribution >= minWeiAmount && tokenContribution >= minTokenAmount, "Too much slipage");

        ethContribution += weiFee;
        tokenContribution += tokenFees;

        // Update reserves
        weiReserves -= ethContribution;
        tokenReserves -= tokenContribution;
        k = weiReserves * tokenReserves;

        // Update liquidity records
        lps[msg.sender] = 0;
        totalLiquidity -= liquidity;
        removeLP(lpProviders.length - 1);

        // Transfer ETH and tokens back to the liquidity provider
        (bool ethSuccess,) = msg.sender.call{value: ethContribution}("");
        require(ethSuccess, "Failed to send ETH");

        bool tokenSuccess = token.transfer(msg.sender, tokenContribution);
        require(tokenSuccess, "Failed to send tokens");
    }
    /**
     *  Define additional functions for liquidity fees here as needed **
     */

    /* ========================= Swap Functions =========================  */

    /// @notice Swaps tokens for ETH
    /// @param tokenAmount how many tokens the sender is swapping
    /// @param minWeiAmount value with applied tolerable slippage
    function swapTokensForETH(uint256 tokenAmount, uint256 minWeiAmount) external {
        require(tokenAmount > 0, "Need tokens to swap");
        require(token.balanceOf(msg.sender) >= tokenAmount, "Not enough tokens");
        require(token.allowance(msg.sender, address(this)) >= tokenAmount, "Not enough token allowed for transfer");

        (uint256 weiAmount, uint256 withFee) = getWeiAmount(tokenAmount);
        require(weiReserves - weiAmount > MIN_LIQUIDITY, "Not enough liquidity");
        require(withFee >= minWeiAmount, "Too much slippage");

        token.transferFrom(msg.sender, address(this), tokenAmount);

        tokenReserves += tokenAmount;
        weiReserves -= withFee;

        (bool succes,) = payable(msg.sender).call{value: withFee}("");
        require(succes, "Transfer failed");
    }

    /// @notice Swaps eth for tokens
    /// @dev msg.value is how many wei the sender is swapping
    /// @param minTokenAmount value with applied tolerable slippage
    function swapETHForTokens(uint256 minTokenAmount) external payable {
        uint256 weiAmount = msg.value;
        require(weiAmount > 0, "Need ETH to swap");

        (uint256 tokenAmount, uint256 withFee) = getTokenAmount(weiAmount);
        require(tokenReserves - tokenAmount > MIN_LIQUIDITY, "Not enough liquidity");
        require(withFee >= minTokenAmount, "Too much slippage");

        weiReserves += weiAmount;
        tokenReserves -= withFee;

        token.transfer(msg.sender, withFee);
    }

    /// @param tokenAmount amount of token to be converted
    /// @return weiAmount value of tokenAmount in wei at current exchange rate
    /// @return withFee value of tokenAmount in wei at current exchange rate with fee accounted for
    function getWeiAmount(uint256 tokenAmount) public view returns (uint256 weiAmount, uint256 withFee) {
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(tokenReserves > 0 && weiReserves > 0, "Invalid reserves");

        return (
            BBLibrary.convertToSwapAmount(tokenAmount, tokenReserves, weiReserves),
            BBLibrary.convertToSwapAmountWithFee(
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
            BBLibrary.convertToSwapAmount(weiAmount, weiReserves, tokenReserves),
            BBLibrary.convertToSwapAmountWithFee(
                weiAmount, weiReserves, tokenReserves, swapFeeNumerator, swapFeeDenominator
                )
        );
    }

    function lpLiquidity(address lp) external view returns (uint256) {
        return lps[lp];
    }

    function lpAt(uint256 index) external view returns (address) {
        return lpProviders[index];
    }
}
