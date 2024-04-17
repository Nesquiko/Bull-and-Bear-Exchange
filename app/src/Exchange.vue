<template>
  <Suspense>
  <div class="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-4 sm:py-6 lg:py-8">
    <div class="block p-6 bg-white border border-gray-200 rounded-lg shadow mb-4 sm:mb-6 lg:mb-8">
      <h5>My Account</h5>
      <div>
        <select aria-label="Select account" v-model="selectedAccount">
          <option v-for="(account, i) in accounts" :key="i" :value="account">{{ account.address }}</option>
        </select>
      </div>
    </div>
    <header>
      <div>
        <h1>{{ exchangeName }}</h1>
        <h2>Decentralized Cryptocurrency Exchange</h2>
      </div>
    </header>
    <div>
      <div>
        <article>
          <div>
            <h1> Current rate: </h1>
            <h3>1 ETH = {{ poolState.tokenEthRate }} {{ tokenSymbol }}</h3>
            <h3>1 {{ tokenSymbol }} = {{ poolState.ethTokenRate }} ETH</h3>
          </div>
          <div>
            <h1>Current Liquidity:</h1>
            <h3>{{ poolState.tokenLiquidity }} {{ tokenSymbol }}</h3>
            <h3>{{ poolState.ethLiquidity }} ETH</h3>
          </div>
          <div>
            <h4> Swap Currencies: </h4>
            <label for="amt-to-swap">Amount:</label>
            <input id="amt-to-swap" type="text" v-model="amtToSwap"/>
            <label for="max-slippage-swap">Maximum Slippage Percentage:</label>
            <input id="max-slippage-swap" type="text" v-model="maxSlippageSwap"/>
            <div>
              <button @click="swapEth">Swap ETH for {{ tokenSymbol }}</button>
              <button @click="swapToken">Swap {{ tokenSymbol }} for ETH</button>
            </div>
          </div>
          <div>
            <h4> Adjust Liquidity: </h4>
            <label for="amt-eth">Amount in Eth:</label>
            <input id="amt-eth" type="text" v-model="amtEth"/>
            <label for="max-slippage-liquid">Maximum Slippage Percentage:</label>
            <input id="max-slippage-liquid" type="text" v-model="maxSlippageLiquid"/>
            <div>
              <button @click="addLiquidity(selectedAccount.address)">Add Liquidity</button>
              <button @click="removeLiquidity">Remove Liquidity</button>
              <button @click="removeAllLiquidity">Remove All Liquidity</button>
            </div>
          </div>
        </article>
        <pre id="log"></pre>
      </div>
    </div>
  </div>
  </Suspense>
</template>

<script setup lang="ts">
import {ref} from 'vue';
import {useSwap} from "@/composables/swap";
import {useLiquidity} from "@/composables/liquidity";
import {
  exchangeName,
  tokenSymbol,
  tokenAddress,
  tokenAbi,
  exchangeAddress,
  exchangeAbi,
  provider,
  tokenContract, exchangeContract
} from '@/constants'
import {ethers} from "ethers";

const accounts = await provider.listAccounts()

const selectedAccount = ref(accounts[0]);

const tokenEthRate = ref(0);
const ethTokenRate = ref(0);

const tokenLiquidity = ref(0);
const ethLiquidity = ref(0);

const {amtToSwap, maxSlippageSwap, swapEth, swapToken} = useSwap();
const {amtEth, maxSlippageLiquid, addLiquidity, removeLiquidity, removeAllLiquidity} = useLiquidity();

const getPoolState = async () => {
  const liquidityTokens = await tokenContract.connect(await provider.getSigner(selectedAccount.value.address)).balanceOf(exchangeAddress);
  const liquidityEth = await provider.getBalance(exchangeAddress);
  return {
    tokenLiquidity: Number(liquidityTokens),
    ethLiquidity: Number(liquidityEth),
    tokenEthRate: Number(liquidityTokens) / Number(liquidityEth) || 0,
    ethTokenRate: Number(liquidityEth) / Number(liquidityTokens) || 0
  };
}

const poolState = await getPoolState()
console.log("starting init");
if (poolState.tokenLiquidity === 0
  && poolState.ethLiquidity === 0) {
  // Call mint twice to make sure mint can be called mutliple times prior to disable_mint
  const total_supply = 100000;
  // await tokenContract.connect(await provider.getSigner(selectedAccount.value.address)).mint(total_supply / 2);
  // await tokenContract.connect(await provider.getSigner(selectedAccount.value.address)).mint(total_supply / 2);
  // await tokenContract.connect(await provider.getSigner(selectedAccount.value.address)).disable_mint();
  // await tokenContract.connect(await provider.getSigner(selectedAccount.value.address)).approve(exchangeAddress, total_supply);
  // tokenContract.connect(await provider.getSigner(selectedAccount.value.address))
  // // initialize pool with equal amounts of ETH and tokens, so exchange rate begins as 1:1
  await exchangeContract.connect(await provider.getSigner(selectedAccount.value.address)).createPool(5000, {value: ethers.parseUnits("5000", "wei")});
}
console.log("init finished");

</script>

<style scoped>
</style>
