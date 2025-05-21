// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TavernGoldToken is ERC20, AccessControl {
    constructor(uint256 initialSupply) ERC20("Tavern Gold", "TGLD") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TOKEN_MINTER_ROLE, msg.sender);
        _mint(msg.sender, initialSupply);
    }

    // Role for users responsible for managing project-wide tasks and permissions
    bytes32 public constant PROJECT_MANAGER_ROLE = keccak256("PROJECT_MANAGER_ROLE");

    // Role for users who contribute to the project in various capacities (non-admin)
    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR_ROLE");

    // Role for accounts allowed to mint new Tavern Gold tokens
    bytes32 public constant TOKEN_MINTER_ROLE = keccak256("TOKEN_MINTER_ROLE");

    // Role for users who manage labels and taxonomy within the application
    bytes32 public constant LABEL_ADMIN_ROLE = keccak256("LABEL_ADMIN_ROLE");

    // Role for frontend developers with access to user-facing feature development
    bytes32 public constant FRONTEND_ROLE = keccak256("FRONTEND_ROLE");

    // Role for backend developers working on services, APIs, and infrastructure
    bytes32 public constant BACKEND_ROLE = keccak256("BACKEND_ROLE");

    // Role for automation engineers handling scripts and CI/CD processes
    bytes32 public constant AUTOMATION_ROLE = keccak256("AUTOMATION_ROLE");

    // Role for security auditors or reviewers of the smart contract and infrastructure
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    // Event emitted when a tip is sent
    event TipSent(address indexed from, address indexed to, uint256 amount, string message);

    /**
     * @dev Allows users to send a tip to another account
     * @param to The address to send the tip to
     * @param amount The amount of tokens to send
     * @param message Optional message accompanying the tip
     */
    function tip(address to, uint256 amount, string memory message) public {
        require(to != address(0), "Cannot tip zero address");
        require(amount > 0, "Tip amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, to, amount);
        emit TipSent(msg.sender, to, amount, message);
    }
}