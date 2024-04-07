import {ref} from "vue";

export const useSwap = () => {
  const amtToSwap = ref('');
  const maxSlippageSwap = ref('');
  const swapEth = () => {
    console.log('swap eth');

    console.log(amtToSwap.value)

    amtToSwap.value = '';
    maxSlippageSwap.value = '';
  }

  const swapToken = () => {
    console.log('swap token');

    amtToSwap.value = '';
    maxSlippageSwap.value = '';
  }

  return {amtToSwap, maxSlippageSwap, swapEth, swapToken}
}
