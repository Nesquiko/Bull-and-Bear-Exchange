<template>
  <div class="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-4 sm:py-6 lg:py-8">
    <div class="block p-6 bg-white border border-gray-200 rounded-lg shadow">
      <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900">My Account</h5>
      <div class="font-normal text-gray-700">
        <select aria-label="Select account" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5" v-model="selectedAccount">
          <option v-for="(account, i) in accounts" :key="i" :value="account">{{ account }}</option>
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
            <h3>1 ETH = {{ tokenEthRate }} {{ tokenSymbol }}</h3>
            <h3>1 {{ tokenSymbol }} = {{ ethTokenRate }} ETH</h3>
          </div>
          <div>
            <h1>Current Liquidity:</h1>
            <h3>{{ tokenLiquidity }} {{ tokenSymbol }}</h3>
            <h3>{{ ethLiquidity }} ETH</h3>
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
              <button @click="addLiquidity">Add Liquidity</button>
              <button @click="removeLiquidity">Remove Liquidity</button>
              <button @click="removeAllLiquidity">Remove All Liquidity</button>
            </div>
          </div>
        </article>
        <pre id="log"></pre>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {ref} from 'vue';
import {useSwap} from "@/composables/swap";
import {useLiquidity} from "@/composables/liquidity";

// Constants
const tokenSymbol = 'Fx'
const exchangeName = 'FxSwap'

const accounts = [
  'aaa',
  'bbb',
  'ccc',
  'ddd',
]

const selectedAccount = ref(accounts[0]);

const tokenEthRate = ref(0);
const ethTokenRate = ref(0);

const tokenLiquidity = ref(0);
const ethLiquidity = ref(0);

const {amtToSwap, maxSlippageSwap, swapEth, swapToken} = useSwap();
const {amtEth, maxSlippageLiquid, addLiquidity, removeLiquidity, removeAllLiquidity} = useLiquidity();

</script>

<style scoped>
</style>
