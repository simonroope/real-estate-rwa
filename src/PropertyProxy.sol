// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

/**
 * @title PropertyProxy
 * @notice Proxy contract for the PropertyToken system that enables upgradeability
 * @dev Uses OpenZeppelin's TransparentUpgradeableProxy pattern
 */
contract PropertyProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, admin_, _data) {}
}
