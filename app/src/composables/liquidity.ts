import { ref } from 'vue';
import {
  exchangeAddress,
  exchangeContract,
  provider,
  tokenContract,
} from '@/constants';

export const useLiquidity = () => {
  const amtEth = ref<number | undefined>(undefined);
  const maxSlippageLiquid = ref<number | undefined>(undefined);

  const addLiquidity = async (selectedAccount: string, ethRate: number) => {
    if (!amtEth.value || !maxSlippageLiquid.value) return;

    const minLiqidity = Math.floor(
      amtEth.value * (1 - maxSlippageLiquid.value / 100)
    );

    const maxTokenAmount = Math.floor(
      amtEth.value * ethRate * (1 + maxSlippageLiquid.value / 100)
    );

    const signer = await provider.getSigner(selectedAccount);

    await tokenContract
      .connect(signer)
      .approve(exchangeAddress, maxTokenAmount);
    await exchangeContract
      .connect(signer)
      .addLiquidity(minLiqidity, maxTokenAmount, { value: amtEth.value });

    amtEth.value = undefined;
    maxSlippageLiquid.value = undefined;
  };

  const removeLiquidity = async (selectedAccount: string, ethRate: number) => {
    if (!amtEth.value || !maxSlippageLiquid.value) return;

    const minWeiAmount = Math.floor(
      amtEth.value * (1 - maxSlippageLiquid.value / 100)
    );
    const minTokenAmount = Math.floor(
      amtEth.value * ethRate * (1 - maxSlippageLiquid.value / 100)
    );

    await exchangeContract
      .connect(await provider.getSigner(selectedAccount))
      .removeLiquidity(amtEth.value, minWeiAmount, minTokenAmount);

    amtEth.value = undefined;
    maxSlippageLiquid.value = undefined;
  };

  const removeAllLiquidity = async (
    selectedAccount: string,
    ethRate: number,
    liquidity: number
  ) => {
    if (!maxSlippageLiquid.value) return;

    const minWeiAmount = Math.floor(
      liquidity * (1 - maxSlippageLiquid.value / 100)
    );
    const minTokenAmount = Math.floor(
      liquidity * ethRate * (1 - maxSlippageLiquid.value / 100)
    );

    await exchangeContract
      .connect(await provider.getSigner(selectedAccount))
      .removeAllLiquidity(minWeiAmount, minTokenAmount);

    amtEth.value = undefined;
    maxSlippageLiquid.value = undefined;
  };

  return {
    amtEth,
    maxSlippageLiquid,
    addLiquidity,
    removeLiquidity,
    removeAllLiquidity,
  };
};
