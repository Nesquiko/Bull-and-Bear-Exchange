<template>
  <Suspense>
    <div class="mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl py-4 sm:py-6 lg:py-8">
      <header>
        <h1>{{ exchangeName }}</h1>
      </header>
      <div
        class="block p-6 bg-white border border-gray-200 rounded-lg shadow mb-4 sm:mb-6 lg:mb-8"
      >
        <h5>Current Account</h5>
        <div>
          <select aria-label="Select account" v-model="selectedAccount">
            <option v-for="(account, i) in accounts" :key="i" :value="account">
              {{ account.address }}
            </option>
          </select>
        </div>
        <div class="grid lg:grid-cols-3 text-center">
          <p class="text-xl">{{ weiBalance }} Wei</p>
          <p class="text-xl">{{ tokenBalance }} {{ tokenSymbol }}</p>
          <p class="text-xl">{{ lps }} Liquidity provided</p>
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
                <div class="grid lg:grid-cols-2 text-center gap-4">
                  <p>1 {{ tokenSymbol }} = {{ poolState.ethTokenRate }} Wei</p>
                  <p>1 ETH = {{ poolState.tokenEthRate }} {{ tokenSymbol }}</p>
                  <p>
                    Swap Fee
                    {{ (poolState.feeNum / poolState.feeDenom) * 100 }}%
                  </p>
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
                  <button @click="swapTokenForWei">
                    Swap {{ tokenSymbol }} for ETH
                  </button>
                </div>
              </div>
            </div>

            <div
              class="block p-6 bg-white border border-gray-200 rounded-lg shadow mb-4 sm:mb-6 lg:mb-8"
            >
              <div>
                <h2>Liquidity</h2>
                <label for="amt-eth">Amount in Eth:</label>
                <input
                  id="amt-eth"
                  class="w-full mt-2 mb-4 rounded-lg border-1 border-gray-300 bg-gray-50"
                  type="number"
                  v-model="amtEth"
                />

                <label for="max-slippage-liquid"
                  >Maximum Slippage Percentage:</label
                >
                <input
                  class="w-full mt-2 mb-4 rounded-lg border-1 border-gray-300 bg-gray-50"
                  id="max-slippage-liquid"
                  type="number"
                  max="100"
                  min="0"
                  v-model="maxSlippageLiquid"
                />
                <div>
                  <button @click="onAddLiquidity()">Add Liquidity</button>
                  <button
                    @click="
                      removeLiquidity(
                        selectedAccount.address,
                        poolState.tokenEthRate
                      )
                    "
                  >
                    Remove Liquidity
                  </button>
                  <button
                    @click="
                      removeAllLiquidity(
                        selectedAccount.address,
                        poolState.tokenEthRate
                      )
                    "
                  >
                    Remove All Liquidity
                  </button>
                </div>
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
  type PoolState,
} from '@/constants';
import { ethers } from 'ethers';

const TOTAL_SUPPLY = 5000n;

const accounts = await provider.listAccounts();

const selectedAccount = ref(accounts[9]);

const { amtToSwap, maxSlippageSwap, swapEth, swapToken } =
  useSwap(exchangeContract);
const {
  amtEth,
  maxSlippageLiquid,
  addLiquidity,
  removeLiquidity,
  removeAllLiquidity,
} = useLiquidity();

const swapWeiForTokens = async () => {
  await swapEth(toRaw(selectedAccount.value), poolState.value);
  poolState.value = await getPoolState();
  updateBalances();
};

const swapTokenForWei = async () => {
  await swapToken(toRaw(selectedAccount.value), poolState.value);
  poolState.value = await getPoolState();
  updateBalances();
};

const weiBalance = ref(0n);
const tokenBalance = ref(0n);
const lps = ref(0n);

const updateBalances = async () => {
  weiBalance.value = await provider.getBalance(selectedAccount.value.address);
  tokenBalance.value = await tokenContract.balanceOf(
    selectedAccount.value.address
  );
  lps.value = await exchangeContract.lpLiquidity(selectedAccount.value.address);
};
updateBalances();

watch(selectedAccount, updateBalances);

const onAddLiquidity = async () => {
  await addLiquidity(
    selectedAccount.value.address,
    poolState.value.tokenEthRate
  );
  poolState.value = await getPoolState();
  updateBalances();
};

const getPoolState = async (): Promise<PoolState> => {
  const liquidityTokens = await tokenContract.balanceOf(exchangeAddress);
  const liquidityEth = await provider.getBalance(exchangeAddress);
  const [feeNum, feeDenom] = await exchangeContract.getSwapFee();
  return calculatePoolState(
    liquidityTokens,
    liquidityEth,
    Number(feeNum),
    Number(feeDenom)
  );
};

const calculatePoolState = (
  liquidityTokens: bigint,
  liquidityEth: bigint,
  feeNum: number,
  feeDenom: number
): PoolState => {
  return {
    tokenLiquidity: Number(liquidityTokens),
    ethLiquidity: Number(liquidityEth),
    tokenEthRate: Number(liquidityTokens) / Number(liquidityEth) || 0,
    ethTokenRate: Number(liquidityEth) / Number(liquidityTokens) || 0,
    feeNum,
    feeDenom,
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
    poolState.value.feeNum,
    poolState.value.feeDenom
  );
  console.log('init finished');
}
</script>

<style scoped></style>
