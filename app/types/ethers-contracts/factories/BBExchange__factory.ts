/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type {
  Signer,
  AddressLike,
  ContractDeployTransaction,
  ContractRunner,
} from "ethers";
import type { NonPayableOverrides } from "../common";
import type { BBExchange, BBExchangeInterface } from "../BBExchange";

const _abi = [
  {
    type: "constructor",
    inputs: [
      {
        name: "bbTokenAddr",
        type: "address",
        internalType: "address",
      },
      {
        name: "initialOwner",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "EXCHANGE_NAME",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "MIN_LIQUIDITY",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "addLiquidity",
    inputs: [
      {
        name: "minWeiAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "tokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "minTokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "createPool",
    inputs: [
      {
        name: "amountTokens",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "getSwapFee",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getTokenAmount",
    inputs: [
      {
        name: "weiAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "tokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "withFee",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getWeiAmount",
    inputs: [
      {
        name: "tokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "weiAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "withFee",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "k",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "lpAt",
    inputs: [
      {
        name: "index",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "lpLiquidity",
    inputs: [
      {
        name: "lp",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owner",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "removeAllLiquidity",
    inputs: [
      {
        name: "minWeiAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "minTokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "removeLiquidity",
    inputs: [
      {
        name: "ethAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "minWeiAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "minTokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "renounceOwnership",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "swapETHForTokens",
    inputs: [
      {
        name: "minTokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "swapTokensForETH",
    inputs: [
      {
        name: "tokenAmount",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "minWeiAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "token",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "contract BBToken",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "tokenReserves",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "totalLiquidity",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "transferOwnership",
    inputs: [
      {
        name: "newOwner",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "weiReserves",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "event",
    name: "OwnershipTransferred",
    inputs: [
      {
        name: "previousOwner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "newOwner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "error",
    name: "OwnableInvalidOwner",
    inputs: [
      {
        name: "owner",
        type: "address",
        internalType: "address",
      },
    ],
  },
  {
    type: "error",
    name: "OwnableUnauthorizedAccount",
    inputs: [
      {
        name: "account",
        type: "address",
        internalType: "address",
      },
    ],
  },
] as const;

const _bytecode =
  "0x60a0604052600060025560006003556003600755606460085534801561002457600080fd5b50604051612343380380612343833981016040819052610043916100fa565b806001600160a01b03811661007257604051631e4fbdf760e01b81526000600482015260240160405180910390fd5b61007b8161008e565b50506001600160a01b031660805261012d565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b80516001600160a01b03811681146100f557600080fd5b919050565b6000806040838503121561010d57600080fd5b610116836100de565b9150610124602084016100de565b90509250929050565b6080516121ae610195600039600081816103bb015281816104f0015281816106d0015281816107a20152818161092901528181610edc015281816110c8015281816112110152818161129c015281816117dd015281816118af01526119e301526121ae6000f3fe60806040526004361061012a5760003560e01c8063857620e1116100ab578063c2507ac11161006f578063c2507ac11461031b578063c49ce20d1461033b578063d4cadf6814610351578063dbf53e3a14610369578063f2fde38b14610389578063fc0c546a146103a957600080fd5b8063857620e1146102515780638da5cb5b146102645780639f81a3b314610296578063a22280a6146102e5578063b4f40c611461030557600080fd5b80634bad9510116100f25780634bad9510146101cb57806358ad6de4146101e1578063715018a6146101f45780638259e6a01461020957806382d5d7ac1461021c57600080fd5b806315770f921461012f57806321b77d63146101585780632eab28411461016d578063335380c514610182578063422f1043146101b8575b600080fd5b34801561013b57600080fd5b5061014560065481565b6040519081526020015b60405180910390f35b34801561016457600080fd5b50610145600181565b61018061017b366004611f3d565b6103dd565b005b34801561018e57600080fd5b5061014561019d366004611f56565b6001600160a01b031660009081526004602052604090205490565b6101806101c6366004611f86565b61056c565b3480156101d757600080fd5b5061014560025481565b6101806101ef366004611fb2565b610b8e565b34801561020057600080fd5b50610180610fa4565b610180610217366004611f3d565b610fb8565b34801561022857600080fd5b5061023c610237366004611f3d565b6113ac565b6040805192835260208301919091520161014f565b61018061025f366004611f86565b61148e565b34801561027057600080fd5b506000546001600160a01b03165b6040516001600160a01b03909116815260200161014f565b3480156102a257600080fd5b506102d86040518060400160405280601681526020017542756c6c20616e6420426561722045786368616e676560501b81525081565b60405161014f9190611fd4565b3480156102f157600080fd5b50610180610300366004611fb2565b611780565b34801561031157600080fd5b5061014560015481565b34801561032757600080fd5b5061023c610336366004611f3d565b611b13565b34801561034757600080fd5b5061014560035481565b34801561035d57600080fd5b5060075460085461023c565b34801561037557600080fd5b5061027e610384366004611f3d565b611be9565b34801561039557600080fd5b506101806103a4366004611f56565b611c19565b3480156103b557600080fd5b5061027e7f000000000000000000000000000000000000000000000000000000000000000081565b34806104235760405162461bcd60e51b815260206004820152601060248201526f04e6565642045544820746f20737761760841b60448201526064015b60405180910390fd5b60008061042f83611b13565b915091506001826002546104439190612039565b116104605760405162461bcd60e51b815260040161041a90612052565b838110156104a45760405162461bcd60e51b8152602060048201526011602482015270546f6f206d75636820736c69707061676560781b604482015260640161041a565b82600360008282546104b69190612080565b9250508190555080600260008282546104cf9190612039565b909155505060405163a9059cbb60e01b8152336004820152602481018290527f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03169063a9059cbb906044016020604051808303816000875af1158015610541573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906105659190612093565b5050505050565b34806105ac5760405162461bcd60e51b815260206004820152600f60248201526e139bc8115512081c1c9bdd9a591959608a1b604482015260640161041a565b8381101561060e5760405162461bcd60e51b815260206004820152602960248201527f6d696e576569416d6f756e742063616e2774206265206d6f7265207468616e206044820152686d73672e76616c756560b81b606482015260840161041a565b600083116106535760405162461bcd60e51b8152602060048201526012602482015271139bc81d1bdad95b9cc81c1c9bdd9a59195960721b604482015260640161041a565b818310156106b95760405162461bcd60e51b815260206004820152602d60248201527f6d696e546f6b656e416d6f756e742063616e2774206265206c6573732074686160448201526c1b881d1bdad95b905b5bdd5b9d609a1b606482015260840161041a565b6040516370a0823160e01b815233600482015283907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906370a0823190602401602060405180830381865afa15801561071f573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061074391906120b5565b10156107855760405162461bcd60e51b81526020600482015260116024820152704e6f7420656e6f75676820746f6b656e7360781b604482015260640161041a565b604051636eb1769f60e11b815233600482015230602482015283907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03169063dd62ed3e90604401602060405180830381865afa1580156107f1573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061081591906120b5565b10156108335760405162461bcd60e51b815260040161041a906120ce565b600080600061084784600354600254611c57565b90508581116108a457848110156108995760405162461bcd60e51b81526020600482015260166024820152753a37b5b2b71038bab7ba32903132b63637bb9036b4b760511b604482015260640161041a565b839250809150610904565b60006108b587600254600354611c57565b9050878110156108fe5760405162461bcd60e51b81526020600482015260146024820152733bb2b49038bab7ba32903132b63637bb9036b4b760611b604482015260640161041a565b92508591505b6040516323b872dd60e01b8152336004820152306024820152604481018390526000907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906323b872dd906064016020604051808303816000875af115801561097a573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061099e9190612093565b9050806109e55760405162461bcd60e51b81526020600482015260156024820152741d1bdad95b881d1c985b9cd9995c8819985a5b1959605a1b604482015260640161041a565b6109ef8486612039565b15610a8957336109ff8587612039565b604051600081818185875af1925050503d8060008114610a3b576040519150601f19603f3d011682016040523d82523d6000602084013e610a40565b606091505b50508091505080610a895760405162461bcd60e51b81526020600482015260136024820152721dd95a481d1c985b9cd9995c8819985a5b1959606a1b604482015260640161041a565b600060035460065486610a9c9190612113565b610aa6919061212a565b3360009081526004602052604081205491925003610b0157600580546001810182556000919091527f036b6384b5eca791c62761152d0c79bb0604c104a5fb6f4eb0703f3154bb3db00180546001600160a01b031916331790555b3360009081526004602052604081208054839290610b20908490612080565b925050819055508060066000828254610b399190612080565b925050819055508460036000828254610b529190612080565b925050819055508360026000828254610b6b9190612080565b9091555050600254600354610b809190612113565b600155505050505050505050565b3360009081526004602052604090205480610beb5760405162461bcd60e51b815260206004820152601d60248201527f4e6f206c697175696469747920666f756e6420666f722073656e646572000000604482015260640161041a565b600060065460035483610bfe9190612113565b610c08919061212a565b90506000600854600654610c1c9190612113565b600354600754610c2c9085612113565b610c369190612113565b610c40919061212a565b90506000610c4d82611b13565b509050600060065460035485610c639190612113565b610c6d919061212a565b90506001600354610c7e9190612039565b811115610ccd5760405162461bcd60e51b815260206004820152601a60248201527f496e73756666696369656e7420776569206c6971756964697479000000000000604482015260640161041a565b6000610cd885611b13565b5090506001600254610cea9190612039565b811115610d395760405162461bcd60e51b815260206004820152601c60248201527f496e73756666696369656e7420746f6b656e206c697175696469747900000000604482015260640161041a565b878210158015610d495750868110155b610d885760405162461bcd60e51b815260206004820152601060248201526f546f6f206d75636820736c697061676560801b604482015260640161041a565b610d928483612080565b9150610d9e8382612080565b90508160036000828254610db29190612039565b925050819055508060026000828254610dcb9190612039565b9091555050600254600354610de09190612113565b60015533600090815260046020526040812081905560068054889290610e07908490612039565b9091555050600554610e2490610e1f90600190612039565b611d14565b6000336001600160a01b0316836040515b60006040518083038185875af1925050503d8060008114610e72576040519150601f19603f3d011682016040523d82523d6000602084013e610e77565b606091505b5050905080610ebd5760405162461bcd60e51b815260206004820152601260248201527108cc2d2d8cac840e8de40e6cadcc8408aa8960731b604482015260640161041a565b60405163a9059cbb60e01b8152336004820152602481018390526000907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03169063a9059cbb906044016020604051808303816000875af1158015610f2d573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610f519190612093565b905080610f985760405162461bcd60e51b81526020600482015260156024820152744661696c656420746f2073656e6420746f6b656e7360581b604482015260640161041a565b50505050505050505050565b610fac611e2e565b610fb66000611e5b565b565b610fc0611e2e565b600254156110105760405162461bcd60e51b815260206004820152601860248201527f546f6b656e20726573657276657320776173206e6f7420300000000000000000604482015260640161041a565b600354156110605760405162461bcd60e51b815260206004820152601760248201527f45544820726573657276657320776173206e6f7420302e000000000000000000604482015260640161041a565b600034116110b05760405162461bcd60e51b815260206004820152601860248201527f4e6565642065746820746f2063726561746520706f6f6c2e0000000000000000604482015260640161041a565b6040516370a0823160e01b81523360048201526000907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906370a0823190602401602060405180830381865afa158015611117573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061113b91906120b5565b90508082111561119f5760405162461bcd60e51b815260206004820152602960248201527f4e6f74206861766520656e6f75676820746f6b656e7320746f20637265617465604482015268081d1a19481c1bdbdb60ba1b606482015260840161041a565b600082116111ef5760405162461bcd60e51b815260206004820152601b60248201527f4e65656420746f6b656e7320746f2063726561746520706f6f6c2e0000000000604482015260640161041a565b6040516323b872dd60e01b8152336004820152306024820152604481018390527f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906323b872dd906064016020604051808303816000875af1158015611262573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906112869190612093565b506040516370a0823160e01b81523060048201527f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906370a0823190602401602060405180830381865afa1580156112eb573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061130f91906120b5565b600281905534600381905561132391612113565b600190815560035460009161133791612039565b336000908152600460205260408120829055600680549293508392909190611360908490612080565b9091555050600580546001810182556000919091527f036b6384b5eca791c62761152d0c79bb0604c104a5fb6f4eb0703f3154bb3db00180546001600160a01b03191633179055505050565b6000806000831161140e5760405162461bcd60e51b815260206004820152602660248201527f546f6b656e20616d6f756e74206d7573742062652067726561746572207468616044820152656e207a65726f60d01b606482015260840161041a565b600060025411801561142257506000600354115b6114615760405162461bcd60e51b815260206004820152601060248201526f496e76616c696420726573657276657360801b604482015260640161041a565b61147083600254600354611eab565b61148584600254600354600754600854611edc565b91509150915091565b600083116114de5760405162461bcd60e51b815260206004820181905260248201527f416d6f756e74206d7573742062652067726561746572207468616e207a65726f604482015260640161041a565b336000908152600460205260409020548061153b5760405162461bcd60e51b815260206004820152601d60248201527f4e6f206c697175696469747920666f756e6420666f722073656e646572000000604482015260640161041a565b8084111561155b5760405162461bcd60e51b815260040161041a90612052565b600060085460065461156d9190612113565b60035460075461157d9088612113565b6115879190612113565b611591919061212a565b9050600061159e82611b13565b5090506000600654600354886115b49190612113565b6115be919061212a565b905060016003546115cf9190612039565b81111561161e5760405162461bcd60e51b815260206004820152601a60248201527f496e73756666696369656e7420776569206c6971756964697479000000000000604482015260640161041a565b600061162988611b13565b509050600160025461163b9190612039565b81111561168a5760405162461bcd60e51b815260206004820152601c60248201527f496e73756666696369656e7420746f6b656e206c697175696469747900000000604482015260640161041a565b86821015801561169a5750858110155b6116d95760405162461bcd60e51b815260206004820152601060248201526f546f6f206d75636820736c697061676560801b604482015260640161041a565b6116e38483612080565b91506116ef8382612080565b905081600360008282546117039190612039565b92505081905550806002600082825461171c9190612039565b90915550506002546003546117319190612113565b60015533600090815260046020526040812080548a9290611753908490612039565b92505081905550876006600082825461176c9190612039565b909155505060405160009033908490610e35565b600082116117c65760405162461bcd60e51b815260206004820152601360248201527204e65656420746f6b656e7320746f207377617606c1b604482015260640161041a565b6040516370a0823160e01b815233600482015282907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906370a0823190602401602060405180830381865afa15801561182c573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061185091906120b5565b10156118925760405162461bcd60e51b81526020600482015260116024820152704e6f7420656e6f75676820746f6b656e7360781b604482015260640161041a565b604051636eb1769f60e11b815233600482015230602482015282907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03169063dd62ed3e90604401602060405180830381865afa1580156118fe573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061192291906120b5565b10156119405760405162461bcd60e51b815260040161041a906120ce565b60008061194c846113ac565b915091506001826003546119609190612039565b1161197d5760405162461bcd60e51b815260040161041a90612052565b828110156119c15760405162461bcd60e51b8152602060048201526011602482015270546f6f206d75636820736c69707061676560781b604482015260640161041a565b6040516323b872dd60e01b8152336004820152306024820152604481018590527f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316906323b872dd906064016020604051808303816000875af1158015611a34573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611a589190612093565b508360026000828254611a6b9190612080565b925050819055508060036000828254611a849190612039565b9091555050604051600090339083908381818185875af1925050503d8060008114611acb576040519150601f19603f3d011682016040523d82523d6000602084013e611ad0565b606091505b50509050806105655760405162461bcd60e51b815260206004820152600f60248201526e151c985b9cd9995c8819985a5b1959608a1b604482015260640161041a565b60008060008311611b725760405162461bcd60e51b8152602060048201526024808201527f57656920616d6f756e74206d7573742062652067726561746572207468616e206044820152637a65726f60e01b606482015260840161041a565b6000600254118015611b8657506000600354115b611bc55760405162461bcd60e51b815260206004820152601060248201526f496e76616c696420726573657276657360801b604482015260640161041a565b611bd483600354600254611eab565b61148584600354600254600754600854611edc565b600060058281548110611bfe57611bfe61214c565b6000918252602090912001546001600160a01b031692915050565b611c21611e2e565b6001600160a01b038116611c4b57604051631e4fbdf760e01b81526000600482015260240161041a565b611c5481611e5b565b50565b6000808411611ca85760405162461bcd60e51b815260206004820152601960248201527f62617365526573657276652063616e2774206265207a65726f00000000000000604482015260640161041a565b600083118015611cb85750600082115b611cf75760405162461bcd60e51b815260206004820152601060248201526f696e76616c696420726573657276657360801b604482015260640161041a565b82611d028386612113565b611d0c919061212a565b949350505050565b6005548110611d7e5760405162461bcd60e51b815260206004820152603060248201527f73706563696669656420696e646578206973206c6172676572207468616e207460448201526f6865206e756d626572206f66206c707360801b606482015260840161041a565b60058054611d8e90600190612039565b81548110611d9e57611d9e61214c565b600091825260209091200154600580546001600160a01b039092169183908110611dca57611dca61214c565b9060005260206000200160006101000a8154816001600160a01b0302191690836001600160a01b031602179055506005805480611e0957611e09612162565b600082815260209020810160001990810180546001600160a01b031916905501905550565b6000546001600160a01b03163314610fb65760405163118cdaa760e01b815233600482015260240161041a565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b600080611eb88584612113565b90506000611ec68686612080565b9050611ed2818361212a565b9695505050505050565b600080611ee98484612039565b9050600087611ef88388612113565b611f029190612113565b90506000611f108984612113565b611f1a868a612113565b611f249190612080565b9050611f30818361212a565b9998505050505050505050565b600060208284031215611f4f57600080fd5b5035919050565b600060208284031215611f6857600080fd5b81356001600160a01b0381168114611f7f57600080fd5b9392505050565b600080600060608486031215611f9b57600080fd5b505081359360208301359350604090920135919050565b60008060408385031215611fc557600080fd5b50508035926020909101359150565b60006020808352835180602085015260005b8181101561200257858101830151858201604001528201611fe6565b506000604082860101526040601f19601f8301168501019250505092915050565b634e487b7160e01b600052601160045260246000fd5b8181038181111561204c5761204c612023565b92915050565b6020808252601490820152734e6f7420656e6f756768206c697175696469747960601b604082015260600190565b8082018082111561204c5761204c612023565b6000602082840312156120a557600080fd5b81518015158114611f7f57600080fd5b6000602082840312156120c757600080fd5b5051919050565b60208082526025908201527f4e6f7420656e6f75676820746f6b656e20616c6c6f77656420666f72207472616040820152643739b332b960d91b606082015260800190565b808202811582820484141761204c5761204c612023565b60008261214757634e487b7160e01b600052601260045260246000fd5b500490565b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052603160045260246000fdfea264697066735822122005bb7db61e85439a588580b3c413b0bdd0bc6104c1631120fa858b3170071fba64736f6c63430008190033";

type BBExchangeConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: BBExchangeConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class BBExchange__factory extends ContractFactory {
  constructor(...args: BBExchangeConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    bbTokenAddr: AddressLike,
    initialOwner: AddressLike,
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(
      bbTokenAddr,
      initialOwner,
      overrides || {}
    );
  }
  override deploy(
    bbTokenAddr: AddressLike,
    initialOwner: AddressLike,
    overrides?: NonPayableOverrides & { from?: string }
  ) {
    return super.deploy(bbTokenAddr, initialOwner, overrides || {}) as Promise<
      BBExchange & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): BBExchange__factory {
    return super.connect(runner) as BBExchange__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): BBExchangeInterface {
    return new Interface(_abi) as BBExchangeInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): BBExchange {
    return new Contract(address, _abi, runner) as unknown as BBExchange;
  }
}
