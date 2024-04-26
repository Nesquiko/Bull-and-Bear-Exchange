import { ref } from 'vue';
import { exchangeContract, provider, tokenContract } from '@/constants';
import { ethers, type JsonRpcSigner } from 'ethers';

export const useLiquidity = () => {
  const amtEth = ref('');
  const maxSlippageLiquid = ref('');

  const addLiquidity = async (selectedAccount: string) => {
    console.log('add liquidity');
    try {
      // TODO: connect to real data
      await exchangeContract
        .connect(await provider.getSigner(selectedAccount))
        .addLiquidity(10, 1000, 10, { value: 10 });
      amtEth.value = '';
      maxSlippageLiquid.value = '';
    } catch (e) {
      console.log(e);
    }
  };

  const removeLiquidity = async (selectedAccount: string) => {
    console.log(selectedAccount);
    try {
      await exchangeContract
        .connect(await provider.getSigner(selectedAccount))
        .removeLiquidity(100);
      amtEth.value = '';
      maxSlippageLiquid.value = '';
    } catch (e) {
      console.log(e);
    }
  };

  const removeAllLiquidity = () => {
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
