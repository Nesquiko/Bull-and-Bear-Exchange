// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * The constant product formula is x * y = k, in our case
 *
 * when swapping token for wei the next formula must hold true:
 *      (x + dx) * (y - dy) = k
 * where dx is amount of tokens swapper wants to swap, and dy is amount of wei
 * which will be received by the swapper.
 *
 * Source of these formulas: https://www.youtube.com/watch?v=IL7cRj5vzEU
 * From the above formula, dy can be calculated like this:
 *      dy  = y -  k
 *                -----
 *                x + dx
 *
 *          = y - xy
 *               -----
 *               x + dx
 *
 *          = xy + ydx - xy
 *            -------------
 *               x + dx
 *
 *          = ydx
 *           -----
 *           x + dx
 *
 * To apply a N% fee, the formula changes to looks like this:
 *
 *      dy  = y * (1 - fee_numerator)  * dx
 *                    --------------
 *                    fee_denominator
 *           ----------------------------------
 *            x + (1 - fee_numerator) * dx
 *                     --------------
 *                     fee_denominator
 *
 *          = y * (fee_denominator - fee_numerator) * dx
 *                  -----------------------------
 *                       fee_denominator
 *           --------------------------------------------------------
 *            x * fee_denominator + (fee_denominator - fee_numerator) * dx
 *               -------------------------------------------------------
 *                       fee_denominator
 *
 *          = y * (fee_denominator - fee_numerator)  * dx
 *           -----------------------------------------------
 *            x * fee_denominator + (fee_denominator - fee_numerator) * dx
 */
library BBLibrary {
    /// @param swapAmount (dx) amount of tokens/wei to convert
    /// @param swapReserve (x) amount of converted asset in reserves
    /// @param targetReserve (y) amount target asset in reserves
    /// @return Amount of the target asset at current exchange rate
    function convertAtExchangeRate(uint256 swapAmount, uint256 swapReserve, uint256 targetReserve)
        internal
        pure
        returns (uint256)
    {
        return (swapAmount * targetReserve) / swapReserve;
    }

    /// @param swapAmount (dx) amount of tokens/wei to swap
    /// @param swapReserve (x) amount of swapped asset in reserves
    /// @param targetReserve (y) amount of asset for which the swapper is swapping
    /// @return Amount of the swap target asset at current exchange rate
    function convertToSwapAmount(uint256 swapAmount, uint256 swapReserve, uint256 targetReserve)
        internal
        pure
        returns (uint256)
    {
        uint256 numerator = targetReserve * swapAmount;
        uint256 denominator = swapReserve + swapAmount;
        return numerator / denominator;
    }

    /// @param swapAmount (dx) amount of tokens/wei to swap
    /// @param swapReserve (x) amount of swapped asset in reserves
    /// @param targetReserve (y) amount of asset for which the swapper is swapping
    /// @param feeNum numerator of the fee fraction
    /// @param feeDenom denominator of the fee fraction
    /// @return Amount of the swap target asset at current exchange rate with fee accounted
    function convertToSwapAmountWithFee(
        uint256 swapAmount,
        uint256 swapReserve,
        uint256 targetReserve,
        uint256 feeNum,
        uint256 feeDenom
    ) internal pure returns (uint256) {
        uint256 feeInverse = feeDenom - feeNum;
        uint256 numerator = targetReserve * feeInverse * swapAmount;
        uint256 denominator = swapReserve * feeDenom + feeInverse * swapAmount;
        return numerator / denominator;
    }
}
