// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {PropertyMethodsV2} from "../src/PropertyMethodsV2.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradePropertySystem is Script {
    function run() public {
        // Get deployment private key from environment or use test key
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0x1234));

        // Get proxy admin and proxy addresses from environment or use test addresses
        address proxyAdminAddress = vm.envOr("PROXY_ADMIN_ADDRESS", address(0x5678));
        address proxyAddress = vm.envOr("PROXY_ADDRESS", address(0x9abc));

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        PropertyMethodsV2 implementationV2 = new PropertyMethodsV2();
        console.log("PropertyMethodsV2 deployed at:", address(implementationV2));

        // Get proxy admin contract
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // Prepare initialization data if needed
        bytes memory data = ""; // Empty data since we don't need to initialize

        console.log("ProxyAdmin address:", address(proxyAdmin));
        console.log("ProxyAdmin owner:", proxyAdmin.owner());
        console.log("Current proxy address:", proxyAddress);

        // Upgrade proxy to new implementation
        proxyAdmin.upgradeAndCall{value: 0}(
            ITransparentUpgradeableProxy(payable(proxyAddress)), 
            address(implementationV2), 
            data
        );
        console.log("Proxy upgraded to new implementation");

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
} 