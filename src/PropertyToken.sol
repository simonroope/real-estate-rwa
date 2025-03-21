// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "./PropertyPool.sol";

/**
 * @title PropertyToken
 * @notice Main entry point for the PropertyToken system
 * @dev This contract delegates all calls to the implementation contract
 */
contract PropertyToken is PropertyPool {
    // Address of the proxy admin contract
    ProxyAdmin public immutable proxyAdmin;
    
    // The proxy that delegates to the implementation
    TransparentUpgradeableProxy public immutable proxy;

    constructor(
        address implementation,
        string memory baseURI
    ) PropertyPool(baseURI) {
        // Deploy the proxy admin
        proxyAdmin = new ProxyAdmin();
        
        // Deploy the proxy pointing to the implementation
        proxy = new TransparentUpgradeableProxy(
            implementation,
            address(proxyAdmin),
            abi.encodeWithSignature("initialize(string)", baseURI)
        );
    }

    /**
     * @dev Fallback function that delegates all calls to the proxy
     */
    fallback() external payable {
        address _proxy = address(proxy);
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _proxy, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev Required to receive ETH
     */
    receive() external payable {}
}
