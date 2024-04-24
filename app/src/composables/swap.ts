import type { BBExchange } from 'types/ethers-contracts';
import { ref } from 'vue';
import { ethers } from 'ethers';
import { exchangeAddress, tokenContract } from '@/constants';

export const useSwap = (exchangeContract: BBExchange) => {
  const amtToSwap = ref<number | undefined>(undefined);
  const maxSlippageSwap = ref<number | undefined>(undefined);

  const swapEth = async (
    tokenEthRate: number,
    signer: ethers.ContractRunner
  ) => {
    if (!amtToSwap.value || !maxSlippageSwap.value) return;

    const options = {
      value: ethers.parseUnits(amtToSwap.value.toString(), 'wei'),
    };
    const withSlippage = Math.floor(
      (1 - maxSlippageSwap.value / 100) * amtToSwap.value * tokenEthRate
    );

    await exchangeContract
      .connect(signer)
      .swapETHForTokens(withSlippage, options);

    amtToSwap.value = undefined;
    maxSlippageSwap.value = undefined;
  };

  const swapToken = async (
    ethTokenRate: number,
    signer: ethers.ContractRunner
  ) => {
    if (!amtToSwap.value || !maxSlippageSwap.value) return;

    await tokenContract
      .connect(signer)
      .approve(exchangeAddress, amtToSwap.value);

    const withSlippage = Math.floor(
      (1 - maxSlippageSwap.value / 100) * amtToSwap.value * ethTokenRate
    );

    await exchangeContract
      .connect(signer)
      .swapTokensForETH(amtToSwap.value, withSlippage);

    amtToSwap.value = undefined;
    maxSlippageSwap.value = undefined;
  };

  return { amtToSwap, maxSlippageSwap, swapEth, swapToken };
};
