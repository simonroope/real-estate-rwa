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
* PropertyToken is the Real Estate ERC1155 token
* PropertyMethods is the implementation contract containing all the business logic
* PropertyPool contains the storage layout
* PropertyProxy is the proxy contract that users interact with


## Deployment Process:
1. Deploy the implementation
```shell
PropertyMethods implementation = new PropertyMethods();
```

2. Deploy the proxy admin
```shell
ProxyAdmin admin = new ProxyAdmin();
```

3. Deploy the proxy with initialization data
```shell
bytes memory data = abi.encodeWithSignature("initialize(string)", baseURI);
PropertyProxy proxy = new PropertyProxy(
    address(implementation),
    address(admin),
    data
);
```

## How Upgrades Work:
All user interactions go through the proxy address
The proxy delegates all calls to the current implementation
To upgrade:
// Deploy new implementation
```shell
PropertyMethods newImplementation = new PropertyMethods();
```

// Through the proxy admin
```shell
admin.upgrade(proxy, address(newImplementation));
```

// Or with initialization data
```shell
admin.upgradeAndCall(
    proxy,
    address(newImplementation),
    abi.encodeWithSignature("initialize(string)", "newBaseURI")
);
```

## Key Points:
* Storage is preserved because it's in the proxy contract
* Only the logic in PropertyMethods can be upgraded
* The storage layout in PropertyPool must remain the same
* Users always interact with the proxy address, not the implementation