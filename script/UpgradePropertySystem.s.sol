// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {PropertyMethodsV2} from "../src/PropertyMethodsV2.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {PropertyProxy} from "../src/PropertyProxy.sol";

contract UpgradePropertySystem is Script {
    function run() public {
        // Get deployment private key from environment or use test key
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0x1234));

        // Get proxy address from environment or use test address
        address proxyAddress = vm.envOr("PROXY_ADDRESS", address(0x9abc));

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        PropertyMethodsV2 implementationV2 = new PropertyMethodsV2();
        console.log("PropertyMethodsV2 deployed at:", address(implementationV2));

        // Get the proxy instance
        console.log("\nAttempting to get proxy instance at:", proxyAddress);
        PropertyProxy proxy = PropertyProxy(payable(proxyAddress));

        // Get the admin address from the proxy
        console.log("\nCalling getAdmin() on proxy");
        address proxyAdminAddress = proxy.getAdmin();
        console.log("ProxyAdmin address:", proxyAdminAddress);

        // Get proxy admin contract
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // Prepare initialization data if needed
        bytes memory data = ""; // Empty data since we don't need to initialize

        // Check if caller is the ProxyAdmin owner
        console.log("ProxyAdmin owner:", proxyAdmin.owner());
        if (proxyAdmin.owner() != msg.sender) {
            console.log("ERROR: Caller is not the ProxyAdmin owner!");
        } else {
            console.log("Owner check passed");
        }

        console.log("\nCalling getImplementation() on proxy");
        address currentImplementation = proxy.getImplementation();
        console.log("Current implementation:", currentImplementation);

        console.log("\nProxy Status:");
        console.log("Current proxy admin:", proxyAdminAddress);
        console.log("Current proxy implementation:", currentImplementation);
        console.log("New implementation:", address(implementationV2));

        // Upgrade proxy to new implementation
        proxyAdmin.upgradeAndCall{value: 0}(
            ITransparentUpgradeableProxy(payable(proxyAddress)), address(implementationV2), data
        );
        console.log("Proxy upgraded to new implementation");

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
