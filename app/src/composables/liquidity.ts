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

    await tokenContract.approve(exchangeAddress, maxTokenAmount);
    await exchangeContract
      .connect(await provider.getSigner(selectedAccount))
      .addLiquidity(minLiqidity, maxTokenAmount, { value: amtEth.value });

    amtEth.value = undefined;
    maxSlippageLiquid.value = undefined;
  };

  const removeLiquidity = async (selectedAccount: string, ethRate: number) => {
    if (!amtEth.value || !maxSlippageLiquid.value) return;
    try {
      await exchangeContract
        .connect(await provider.getSigner(selectedAccount))
        .removeLiquidity(
          100,
          amtEth.value * (maxSlippageLiquid.value / 100),
          amtEth.value * ethRate * (maxSlippageLiquid.value / 100)
        );
      amtEth.value = '';
      maxSlippageLiquid.value = '';
    } catch (e) {
      console.log(e);
    }
  };

  const removeAllLiquidity = async (
    selectedAccount: string,
    ethRate: number
  ) => {
    if (!maxSlippageLiquid.value) return;
    try {
      await exchangeContract
        .connect(await provider.getSigner(selectedAccount))
        .removeAllLiquidity(
          amtEth.value * (maxSlippageLiquid.value / 100),
          amtEth.value * ethRate * (maxSlippageLiquid.value / 100)
        );
      amtEth.value = '';
      maxSlippageLiquid.value = '';
    } catch (e) {
      console.log(e);
    }

    console.log('remove all liquidity');

    maxSlippageLiquid.value = '';
  };
  return {
    amtEth,
    maxSlippageLiquid,
    addLiquidity,
    removeLiquidity,
    removeAllLiquidity,
  };
};
