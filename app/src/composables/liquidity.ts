import { ref } from 'vue';
import { exchangeContract, provider } from '@/constants';

export const useLiquidity = () => {
  const amtEth = ref('');
  const maxSlippageLiquid = ref('');

  const addLiquidity = async (selectedAccount: string, ethRate: number) => {
    console.log('add liquidity');
    if (!amtEth.value || !maxSlippageLiquid.value) return;
    try {
      await exchangeContract
        .connect(await provider.getSigner(selectedAccount))
        // value = input [0]=input*percetage [1]=input*rate [2]=input*rate*percentage
        // 160 90 60 200  (1.rate)
        // TODO remove all liquidty, add real values to add/remove
        .addLiquidity(
          amtEth.value * (maxSlippageLiquid.value / 100),
          amtEth.value * ethRate,
          amtEth.value * ethRate * (maxSlippageLiquid.value / 100),
          { value: amtEth.value }
        );
      amtEth.value = '';
      maxSlippageLiquid.value = '';
    } catch (e) {
      console.log(e);
    }
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

  const removeAllLiquidity = (selectedAccount: string, ethRate: number) => {
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
