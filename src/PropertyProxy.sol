// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title PropertyProxy
 * @notice Proxy contract for the PropertyToken system that enables upgradeability
 * @dev Uses OpenZeppelin's TransparentUpgradeableProxy pattern
 */
contract PropertyProxy is TransparentUpgradeableProxy, ERC1155 {
    using Strings for uint256;

    // Storage variables
    string private _baseURI;
    mapping(uint256 => PropertyData) public propertyData;
    mapping(address => uint256[]) public userProperties;
    mapping(address => uint256[]) public userInvestments;
    mapping(address => bool) public authorizedMinters;

    // Structs
    struct PropertyData {
        uint256 totalShares;
        uint256 availableShares;
        address propertyOwner;
        bool exists;
        address[] shareholders;
        mapping(address => uint256) shareholderShares;
    }

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, admin_, _data) ERC1155("") {}

    // Override uri to use our storage
    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    // Handle incoming ETH
    receive() external payable {}
}
