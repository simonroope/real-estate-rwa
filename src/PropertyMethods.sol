// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./PropertyPool.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

/**
 * @title PropertyTokenImpl
 * @notice Implementation contract for property creation and management
 * @dev This contract contains the logic that the proxy will delegate to
 */
contract PropertyTokenImpl is PropertyPool {
    using Strings for uint256;

    // Events
    event PropertyCreated(uint256 indexed propertyId, uint256 totalShares);
    event SharesMinted(uint256 indexed propertyId, address to, uint256 amount);
    event SharesBurned(uint256 indexed propertyId, address from, uint256 amount);
    event MinterAuthorized(address indexed minter);
    event MinterRevoked(address indexed minter);
    event PropertyOwnershipChanged(uint256 indexed propertyId, address indexed oldOwner, address indexed newOwner);
    event ShareholderAdded(uint256 indexed propertyId, address indexed shareholder);

    // Errors
    error NotAuthorizedMinter();
    error InvalidTokenId();
    error PropertyAlreadyExists();
    error PropertyDoesNotExist();
    error InvalidShareAmount();
    error NotPropertyOwner();
    error CannotTransferToZeroAddress();
    error AlreadyInitialized();

    bool private initialized;

    modifier onlyAuthorizedMinter() {
        if (!authorizedMinters[msg.sender]) revert NotAuthorizedMinter();
        _;
    }

    /**
     * @notice Initialize the implementation contract
     * @dev This replaces the constructor for upgradeable contracts
     * @param baseURI The base URI for token metadata
     */
    function initialize(string memory baseURI) external {
        if (initialized) revert AlreadyInitialized();
        _baseURI = baseURI;
        initialized = true;
    }

    /**
     * @notice Create a new property with its associated shares
     * @param to Recipient address for the property NFT
     * @param propertyId Token ID for the property (must be even)
     * @param totalShares Total number of shares to create for this property
     */
    function createProperty(
        address to,
        uint256 propertyId,
        uint256 totalShares
    ) external onlyAuthorizedMinter {
        if (propertyId % 2 != 0) revert InvalidTokenId();
        if (propertyData[propertyId].exists) revert PropertyAlreadyExists();
        if (totalShares == 0) revert InvalidShareAmount();
        if (to == address(0)) revert CannotTransferToZeroAddress();

        // Create property data
        PropertyData storage newProperty = propertyData[propertyId];
        newProperty.totalShares = totalShares;
        newProperty.availableShares = totalShares;
        newProperty.propertyOwner = to;
        newProperty.exists = true;

        // Add property to owner's list
        userProperties[to].push(propertyId);

        // Mint property NFT
        _mint(to, propertyId, 1, "");

        // Mint all shares to the contract
        _mint(address(this), propertyId + 1, totalShares, "");

        emit PropertyCreated(propertyId, totalShares);
        emit PropertyOwnershipChanged(propertyId, address(0), to);
    }

    /**
     * @notice Transfer shares from the contract to a buyer
     * @param to Recipient address
     * @param propertyId Property token ID (must be even)
     * @param amount Number of shares to transfer
     */
    function transferShares(
        address to,
        uint256 propertyId,
        uint256 amount
    ) external onlyAuthorizedMinter {
        PropertyData storage property = propertyData[propertyId];
        if (!property.exists) revert PropertyDoesNotExist();
        if (amount > property.availableShares) revert InvalidShareAmount();
        if (to == address(0)) revert CannotTransferToZeroAddress();

        uint256 shareId = propertyId + 1;
        property.availableShares -= amount;
        
        // Update shareholder data
        if (property.shareholderShares[to] == 0) {
            property.shareholders.push(to);
            userInvestments[to].push(propertyId);
            emit ShareholderAdded(propertyId, to);
        }
        property.shareholderShares[to] += amount;

        _safeTransferFrom(address(this), to, shareId, amount, "");
        emit SharesMinted(propertyId, to, amount);
    }

    /**
     * @notice Get property data
     * @param propertyId Property token ID
     */
    function getPropertyData(uint256 propertyId) external view returns (
        uint256 totalShares,
        uint256 availableShares,
        address propertyOwner,
        bool exists
    ) {
        PropertyData storage property = propertyData[propertyId];
        return (
            property.totalShares,
            property.availableShares,
            property.propertyOwner,
            property.exists
        );
    }

    /**
     * @notice Get the share balance of an address for a property
     * @param propertyId Property token ID
     * @param owner Address to check
     */
    function getShareBalance(uint256 propertyId, address owner) external view returns (uint256) {
        return balanceOf(owner, propertyId + 1);
    }

    /**
     * @notice Authorize a new minter
     * @param minter Address to authorize
     */
    function authorizeMinter(address minter) external onlyOwner {
        authorizedMinters[minter] = true;
        emit MinterAuthorized(minter);
    }

    /**
     * @notice Get the URI for a token's metadata
     * @param tokenId Token ID to query
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    /**
     * @notice Check if an address is an authorized minter
     * @param minter Address to check
     */
    function isAuthorizedMinter(address minter) external view returns (bool) {
        return authorizedMinters[minter];
    }
}