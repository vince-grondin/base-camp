# base-camp
Implementation of solutions to the exercises of [the Base Camp](https://docs.base.org/base-camp/docs/welcome/).

This codebase uses Foundry, a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.

## Deployment, Verification and Submission
### Deployment
#### Pre-requisites
##### Set up wallet
Set up your preferred wallet (eg. Coinbase Wallet), enable the Base Goerli Testnet and fund your Ethereum address with
test ETH (eg. using the [Bware Labs Base Faucet](https://bwarelabs.com/faucets/base-testnet)).

##### Enable auto-compile
In the `Solidity compiler` settings check the `Auto compile` checkbox.

#### Deployment Steps
One simple but manual approach to deploying contracts to a network consists of the following steps:
1) Navigate to the official Remix IDE website: https://remix.ethereum.org/
2) Create a new workspace using the `Basic` template and name it as desired (eg. `base-camp`)
3) Add a new file under the `contracts` directory with the name of the contract you're looking to deploy (eg. `BasicMath.sol`)
4) Select `Injected Provider` and **make sure that Base Görli network is selected**
5) Select the contract you're looking to deploy in the `CONTRACT` dropdown
6) Hit the deploy button (after configuring any deployment options that may be needed for your contract)

#### Verification Steps
After deploying a contract,
1) Copy the address of the deployed contract (eg. hit the `Copy` button under the `Deployed Contracts` section on the
`Deploy and run transactions` panel in the Remix IDE)
2) Navigate to Base Scan: `https://goerli.basescan.org/address/<contract address here>`
3) Click on the `Contract` tab
4) Click on `Verify & Publish` and follow the steps

#### Submission for testnet NFT
1) Navigate to the exercise page (eg. [Control Structures Exercise](https://docs.base.org/base-camp/docs/control-structures/control-structures-exercise))
2) Hit the `Connect` button to connect your desired wallet. This does not have to be the same wallet or used to deploy
the contract, it can be any of your wallets. Make sure to select the Base Görli network in your wallet.
3) Paste the address of the contract you're looking to submit in the `Contract address` input field
4) Hit the `Submit` button and confirm in your wallet

## Foundry Commands

Foundry consists of:
- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
