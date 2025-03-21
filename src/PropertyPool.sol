// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PropertyPool
 * @notice Storage contract for PropertyToken system
 */
contract PropertyPool is ERC1155, Ownable {
    // Base URI for token metadata
    string internal _baseURI;
    
    // Property specific data
    struct PropertyData {
        uint256 totalShares;
        uint256 availableShares;
        address propertyOwner;
        mapping(address => uint256) shareholderShares;
        address[] shareholders;
        bool exists;
    }
    
    // Storage variables
    mapping(uint256 => PropertyData) internal propertyData;
    mapping(address => uint256[]) internal userProperties;
    mapping(address => uint256[]) internal userInvestments;
    mapping(address => bool) internal authorizedMinters;

    // Constructor
    constructor(string memory baseURI) ERC1155(baseURI) Ownable(msg.sender) {
        _baseURI = baseURI;
    }
}