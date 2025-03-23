// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {console} from "forge-std/console.sol";
/**
 * @title PropertyProxy
 * @notice Proxy contract for the PropertyToken system that enables upgradeability
 * @dev Uses OpenZeppelin's TransparentUpgradeableProxy pattern
 */

contract PropertyProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address admin_, bytes memory _data)
        TransparentUpgradeableProxy(_logic, admin_, _data)
    {
        console.log("PropertyProxy constructor called");
        console.log("Logic address:", _logic);
        console.log("Admin address:", admin_);
    }

    function getAdmin() external view returns (address) {
        console.log("PropertyProxy.getAdmin called");
        address admin = ERC1967Utils.getAdmin();
        console.log("Admin from ERC1967Utils:", admin);
        return admin;
    }

    function getImplementation() external view returns (address) {
        console.log("PropertyProxy.getImplementation called");
        address impl = ERC1967Utils.getImplementation();
        console.log("Implementation from ERC1967Utils:", impl);
        return impl;
    }

    // Handle incoming ETH
    receive() external payable {}
}
