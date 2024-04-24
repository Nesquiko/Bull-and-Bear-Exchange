<template>
  <Suspense>
    <div class="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-4 sm:py-6 lg:py-8">
      <header>
        <h1>{{ exchangeName }}</h1>
      </header>
      <div
        class="block p-6 bg-white border border-gray-200 rounded-lg shadow mb-4 sm:mb-6 lg:mb-8"
      >
        <h5>My Account with balance: ???</h5>
        <div>
          <select aria-label="Select account" v-model="selectedAccount">
            <option v-for="(account, i) in accounts" :key="i" :value="account">
              {{ account.address }}
            </option>
          </select>
        </div>
      </div>
      <div>
        <div>
          <article>
            <div>
              <div
                class="block p-6 bg-white border border-gray-200 rounded-lg shadow mb-4 sm:mb-6 lg:mb-8"
              >
                <h2>Swap</h2>
                <div class="grid grid-cols-3 text-center gap-4">
                  <p>1 {{ tokenSymbol }} = {{ poolState.ethTokenRate }} Wei</p>
                  <p>Swap Fee {{ poolState.fee }}%</p>
                  <p>
                    Liquidity {{ poolState.tokenLiquidity }} {{ tokenSymbol }} :
                    {{ poolState.ethLiquidity }} Wei
                  </p>
                </div>
                <label for="amt-to-swap">Amount:</label>
                <input
                  class="w-full mt-2 mb-4 rounded-lg border-1 border-gray-300 bg-gray-50"
                  id="amt-to-swap"
                  type="number"
                  v-model="amtToSwap"
                />
                <label for="max-slippage-swap"
                  >Maximum Slippage Percentage:</label
                >
                <input
                  class="w-full mt-2 mb-4 rounded-lg border-1 border-gray-300 bg-gray-50"
                  id="max-slippage-swap"
                  type="number"
                  max="100"
                  min="0"
                  v-model="maxSlippageSwap"
                />
                <div>
                  <button @click="swapWeiForTokens">
                    Swap ETH for {{ tokenSymbol }}
                  </button>
                  <button @click="swapToken">
                    Swap {{ tokenSymbol }} for ETH
                  </button>
                </div>
              </div>
            </div>

            <div>
              <h1>Current rate:</h1>
              <h3>
                1 ETH = {{ poolState.tokenEthRate }}
                {{ tokenSymbol }}
              </h3>
              <h3>1 {{ tokenSymbol }} = {{ poolState.ethTokenRate }} ETH</h3>
            </div>
            <div>
              <h1>Current Liquidity:</h1>
              <h3>{{ poolState.tokenLiquidity }} {{ tokenSymbol }}</h3>
              <h3>{{ poolState.ethLiquidity }} Wei</h3>
            </div>
            <div>
              <h4>Adjust Liquidity:</h4>
              <label for="amt-eth">Amount in Eth:</label>
              <input id="amt-eth" type="text" v-model="amtEth" />
              <label for="max-slippage-liquid"
                >Maximum Slippage Percentage:</label
              >
              <input
                id="max-slippage-liquid"
                type="text"
                v-model="maxSlippageLiquid"
              />
              <div>
                <button @click="addLiquidity(selectedAccount.address)">
                  Add Liquidity
                </button>
                <button @click="removeLiquidity">Remove Liquidity</button>
                <button @click="removeAllLiquidity">
                  Remove All Liquidity
                </button>
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
import { ref, toRaw, watch } from 'vue';
import { useSwap } from '@/composables/swap';
import { useLiquidity } from '@/composables/liquidity';
import {
  exchangeName,
  tokenSymbol,
  exchangeAddress,
  provider,
  tokenContract,
  exchangeContract,
} from '@/constants';
import { ethers } from 'ethers';

const TOTAL_SUPPLY = 5000n;

const accounts = await provider.listAccounts();

const selectedAccount = ref(accounts[9]);

const tokenEthRate = ref(0);
const ethTokenRate = ref(0);

const tokenLiquidity = ref(0);
const ethLiquidity = ref(0);

const { amtToSwap, maxSlippageSwap, swapEth, swapToken } =
  useSwap(exchangeContract);
const {
  amtEth,
  maxSlippageLiquid,
  addLiquidity,
  removeLiquidity,
  removeAllLiquidity,
} = useLiquidity();

watch(selectedAccount, async () => {
  //   TODO
});

const swapWeiForTokens = async () => {
  await swapEth(poolState.value.tokenEthRate, toRaw(selectedAccount.value));
  poolState.value = await getPoolState();
};

const getPoolState = async () => {
  const liquidityTokens = await tokenContract.balanceOf(exchangeAddress);
  const liquidityEth = await provider.getBalance(exchangeAddress);
  const [feeNum, feeDenom] = await exchangeContract.getSwapFee();
  const fee = Number(feeNum) / Number(feeDenom);
  return calculatePoolState(liquidityTokens, liquidityEth, fee);
};

const calculatePoolState = (
  liquidityTokens: bigint,
  liquidityEth: bigint,
  fee: number
) => {
  return {
    tokenLiquidity: Number(liquidityTokens),
    ethLiquidity: Number(liquidityEth),
    tokenEthRate: Number(liquidityTokens) / Number(liquidityEth) || 0,
    ethTokenRate: Number(liquidityEth) / Number(liquidityTokens) || 0,
    fee,
  };
};

let poolState = ref(await getPoolState());
if (
  poolState.value.tokenLiquidity === 0 &&
  poolState.value.ethLiquidity === 0
) {
  console.log('starting init');
  // initialize pool with equal amounts of ETH and tokens, so exchange rate begins as 1:1
  const owner = accounts[0];
  await tokenContract.connect(owner).approve(exchangeAddress, TOTAL_SUPPLY);
  const options = { value: ethers.parseUnits('5000', 'wei') };
  await exchangeContract.connect(owner).createPool(TOTAL_SUPPLY, options);
  poolState.value = calculatePoolState(
    TOTAL_SUPPLY,
    TOTAL_SUPPLY,
    poolState.value.fee
  );
  console.log('init finished');
}
</script>

<style scoped></style>
