import {ref} from "vue";

export const useLiquidity = () => {
  const amtEth = ref('');
  const maxSlippageLiquid = ref('');

  const addLiquidity = () => {
    console.log('add liquidity');

    amtEth.value = '';
    maxSlippageLiquid.value = '';
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
