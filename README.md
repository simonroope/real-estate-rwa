## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

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

# Real Estate RWA
## Initial Setup:
* PropertyToken is the immutable Real Estate ERC1155 token
* PropertyProxy is the proxy contract that users interact with
* PropertyMethodsV1 is the implementation contract containing the business logic
* PropertyMethodsV2 is the implementation contract containing additional business logic


## Deployment and Upgrades:
All user interactions go through the proxy address
The proxy delegates all calls to the current implementation

### Initial deploy:
// Deploy new implementation contract
```shell
PropertyMethodsV1 implementationV1 = new PropertyMethodsV1();
```

// PropertyProxy delegates to implementation contract using ProxyAdmin controller. 
```shell
TransparentUpgradeableProxy propertyProxy =
            new TransparentUpgradeableProxy(address(implementationV1), address(proxyAdmin), data);
```

### Upgrade:
// Deploy revised implementation contract
```shell
PropertyMethodsV2 implementationV2 = new PropertyMethodsV2();
```

// PropertyProxy delegates to new implementation contract, again using ProxyAdmin controller. 
```shell
 proxyAdmin.upgradeAndCall{value: 0}(
            ITransparentUpgradeableProxy(payable(proxyAddress)), address(implementationV2),
            data
        );
```

## Key Points:
* The proxy contract holds all the storage data
* Storage is preserved because all storage variables remain in the proxy contract's storage. 
* The implementation contracts (PropertyMethodsV1 and PropertyMethodsV2) only contain the logic.
* The PropertyToken is immutable and referenced by the implementation contracts.
* Only the PropertyMethods contracts can be upgraded. The upgrade just changes which implementation contract the proxy points to.
* Users always interact with the proxy contract address, not the implementation.