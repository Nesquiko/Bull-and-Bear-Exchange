import {ref} from "vue";
import {exchangeAddress, exchangeContract, provider, tokenContract} from "@/constants";

export const useLiquidity = () => {
  const amtEth = ref('');
  const maxSlippageLiquid = ref('');

  const addLiquidity = async (selectedAccount: string) => {
    console.log('add liquidity');
    try {
      const liquidityTokens = await exchangeContract.connect(await provider.getSigner(selectedAccount.address)).addLiquidity(tokenContract.address, amtEth.value, maxSlippageLiquid.value);
      amtEth.value = '';
      maxSlippageLiquid.value = '';
    } catch (e) {
      console.log(e)
    }
  }

  const removeLiquidity = () => {
    console.log('remove liquidity');

    amtEth.value = '';
    maxSlippageLiquid.value = '';
  }

  const removeAllLiquidity = () => {
    console.log('remove all liquidity');

    maxSlippageLiquid.value = '';
  }
  return {amtEth, maxSlippageLiquid, addLiquidity, removeLiquidity, removeAllLiquidity}
}
