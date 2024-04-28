import { ethers } from 'ethers';
import {
  BBExchange__factory,
  BBToken__factory,
} from '../types/ethers-contracts';

export const tokenSymbol = 'BBT';
export const exchangeName = 'Bull and Bear Exchange';

export const tokenAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
export const exchangeAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';

export const provider = new ethers.JsonRpcProvider('http://localhost:8545');

export const tokenContract = BBToken__factory.connect(
  tokenAddress,
  await provider.getSigner()
);
export const exchangeContract = BBExchange__factory.connect(
  exchangeAddress,
  await provider.getSigner()
);

export interface PoolState {
  tokenLiquidity: number;
  ethLiquidity: number;
  tokenEthRate: number;
  ethTokenRate: number;
  feeNum: number;
  feeDenom: number;
}
