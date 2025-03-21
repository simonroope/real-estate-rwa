// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "./PropertyPool.sol";

/**
 * @title PropertyTokenProxy
 * @notice Proxy contract for the PropertyToken system that enables upgradeability
 * @dev Uses OpenZeppelin's TransparentUpgradeableProxy pattern
 */
contract PropertyTokenProxy is PropertyPool {
    // Immutable proxy admin for managing upgrades
    address public immutable proxyAdmin;
    
    // Implementation version tracking
    uint256 public implementationVersion;
    
    // Current implementation address
    address public implementation;

    event ImplementationUpgraded(address indexed newImplementation, uint256 version);
    event AdminChanged(address indexed newAdmin);

    error OnlyProxyAdmin();
    error InvalidImplementation();
    error InitializationFailed();

    modifier onlyProxyAdmin() {
        if (msg.sender != proxyAdmin) revert OnlyProxyAdmin();
        _;
    }

    constructor(
        address _implementation,
        address _proxyAdmin,
        string memory baseURI
    ) PropertyPool(baseURI) {
        if (_implementation == address(0)) revert InvalidImplementation();
        if (_proxyAdmin == address(0)) revert InvalidImplementation();

        proxyAdmin = _proxyAdmin;
        implementation = _implementation;
        implementationVersion = 1;

        // Initialize the implementation
        (bool success, ) = _implementation.delegatecall(
            abi.encodeWithSignature("initialize(string)", baseURI)
        );
        if (!success) revert InitializationFailed();

        emit ImplementationUpgraded(_implementation, 1);
    }

    /**
     * @notice Upgrade to a new implementation contract
     * @param newImplementation Address of the new implementation
     */
    function upgradeTo(address newImplementation) external onlyProxyAdmin {
        if (newImplementation == address(0)) revert InvalidImplementation();
        if (newImplementation == implementation) revert InvalidImplementation();

        implementation = newImplementation;
        implementationVersion++;

        emit ImplementationUpgraded(newImplementation, implementationVersion);
    }

    /**
     * @notice Upgrade to a new implementation and call a function
     * @param newImplementation Address of the new implementation
     * @param data Function call data to execute
     */
    function upgradeToAndCall(
        address newImplementation, 
        bytes memory data
    ) external onlyProxyAdmin {
        upgradeTo(newImplementation);

        (bool success, ) = newImplementation.delegatecall(data);
        if (!success) revert InitializationFailed();
    }

    /**
     * @dev Fallback function that delegates calls to the implementation
     */
    fallback() external payable virtual {
        address _implementation = implementation;
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

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
    receive() external payable virtual {}

    /**
     * @notice Get the current implementation address
     */
    function getImplementation() external view returns (address) {
        return implementation;
    }

    /**
     * @notice Get the proxy admin address
     */
    function getAdmin() external view returns (address) {
        return proxyAdmin;
    }
}