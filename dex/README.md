# Bull and Bear Exchange Smart contracts

## Compile

```bash
forge build
```

ABIs of contracts can be found in _./out/COMPILED-CONTRACT.sol/COMPILED-CONTRACT.json_.
With [jq](https://github.com/jqlang/jq) it can be printed to console like this:

```bash
forge build --silent && jq '.abi' ./out/COMPILED-CONTRACT.sol/COMPILED-CONTRACT.json
```

## Run tests

```bash
forge test
```

To run specific test add `--match-test PATTERN-TO-MATCH` to the previous command.

To enable/increase logging level during tests, add `-v`/`-vv...` to the previous command.

For test code coverage run:

```bash
forge coverage
```

## Deploy

To deploy on local anvil chain:

```bash
forge script ./script/DeployContracts.s.sol --rpc-url 'http://127.0.0.1:8545' --broadcast -vvvv
```

To deploy on Sepolia testnet (_.env_ required):

```bash
source .env; forge script ./script/DeployContracts.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
```

## Documentation

Generate docs from [NatSpec](https://docs.soliditylang.org/en/latest/natspec-format.html)
in solidity code, and serve it locally with:

```bash
forge doc --serve --port 4000
```

## Static analysis

Install [Slither](https://github.com/crytic/slither?tab=readme-ov-file)
and run

```bash
slither .
```
