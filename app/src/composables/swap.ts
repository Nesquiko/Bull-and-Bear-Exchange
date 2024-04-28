import type { BBExchange } from 'types/ethers-contracts';
import { ref } from 'vue';
import { ethers } from 'ethers';
import { exchangeAddress, tokenContract, type PoolState } from '@/constants';

export const useSwap = (exchangeContract: BBExchange) => {
  const amtToSwap = ref<number | undefined>(undefined);
  const maxSlippageSwap = ref<number | undefined>(undefined);

  const swapEth = async (
    signer: ethers.ContractRunner,
    poolState: PoolState
  ) => {
    if (!amtToSwap.value || !maxSlippageSwap.value) return;

    const options = {
      value: ethers.parseUnits(amtToSwap.value.toString(), 'wei'),
    };
    // const withSlippage = Math.floor(
    //   (1 - maxSlippageSwap.value / 100) * amtToSwap.value * tokenEthRate
    // );
    const swapAmount = calculateSwap(
      amtToSwap.value,
      poolState.ethLiquidity,
      poolState.tokenLiquidity,
      poolState.feeNum,
      poolState.feeDenom
    );
    const withSlippage = Math.floor(
      (1 - maxSlippageSwap.value / 100) * swapAmount
    );

    await exchangeContract
      .connect(signer)
      .swapETHForTokens(withSlippage, options);

    amtToSwap.value = undefined;
    maxSlippageSwap.value = undefined;
  };

  const swapToken = async (
    signer: ethers.ContractRunner,
    poolState: PoolState
  ) => {
    if (!amtToSwap.value || !maxSlippageSwap.value) return;

    await tokenContract
      .connect(signer)
      .approve(exchangeAddress, amtToSwap.value);

    const swapAmount = calculateSwap(
      amtToSwap.value,
      poolState.tokenLiquidity,
      poolState.ethLiquidity,
      poolState.feeNum,
      poolState.feeDenom
    );
    const withSlippage = Math.floor(
      (1 - maxSlippageSwap.value / 100) * swapAmount
    );

    await exchangeContract
      .connect(signer)
      .swapTokensForETH(amtToSwap.value, withSlippage);

    amtToSwap.value = undefined;
    maxSlippageSwap.value = undefined;
  };

  return { amtToSwap, maxSlippageSwap, swapEth, swapToken };
};

const calculateSwap = (
  swapAmount: number,
  swapReserve: number,
  targetReserve: number,
  feeNum: number,
  feeDenom: number
): number => {
  const feeInverse = feeDenom - feeNum;
  const numerator = targetReserve * feeInverse * swapAmount;
  const denominator = swapReserve * feeDenom + feeInverse * swapAmount;
  return numerator / denominator;
};
