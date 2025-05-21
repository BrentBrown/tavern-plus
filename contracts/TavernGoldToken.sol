// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


// TavernGoldToken is an ERC20 token with a faucet and tip functionality
contract TavernGoldToken is ERC20, AccessControl {
    
    // Constructor that initializes the token with an initial supply and grants roles to the deployer
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

    // Mapping to store user account numbers
    mapping(address => uint256) private _accountNumbers;
    uint256 private _nextAccountNumber = 1;

    // Event emitted when a new account is registered
    event AccountRegistered(address indexed user, uint256 accountNumber);

    /**
     * @dev Returns the account number for a given address
     * @param account The address to get the account number for
     * @return The account number (0 if not registered)
     */
    function getAccountNumber(address account) public view returns (uint256) {
        return _accountNumbers[account];
    }

    /**
     * @dev Returns all roles that an address has
     * @param account The address to get roles for
     * @return An array of role names that the address has
     */
    function getRoles(address account) public view returns (string[] memory) {
        bytes32[] memory allRoles = new bytes32[](9);
        allRoles[0] = DEFAULT_ADMIN_ROLE;
        allRoles[1] = PROJECT_MANAGER_ROLE;
        allRoles[2] = CONTRIBUTOR_ROLE;
        allRoles[3] = TOKEN_MINTER_ROLE;
        allRoles[4] = LABEL_ADMIN_ROLE;
        allRoles[5] = FRONTEND_ROLE;
        allRoles[6] = BACKEND_ROLE;
        allRoles[7] = AUTOMATION_ROLE;
        allRoles[8] = AUDITOR_ROLE;

        // Count how many roles the account has
        uint256 roleCount = 0;
        for (uint256 i = 0; i < allRoles.length; i++) {
            if (hasRole(allRoles[i], account)) {
                roleCount++;
            }
        }

        // Create array of role names
        string[] memory roles = new string[](roleCount);
        uint256 currentIndex = 0;
        
        if (hasRole(DEFAULT_ADMIN_ROLE, account)) roles[currentIndex++] = "Admin";
        if (hasRole(PROJECT_MANAGER_ROLE, account)) roles[currentIndex++] = "Project Manager";
        if (hasRole(CONTRIBUTOR_ROLE, account)) roles[currentIndex++] = "Contributor";
        if (hasRole(TOKEN_MINTER_ROLE, account)) roles[currentIndex++] = "Token Minter";
        if (hasRole(LABEL_ADMIN_ROLE, account)) roles[currentIndex++] = "Label Admin";
        if (hasRole(FRONTEND_ROLE, account)) roles[currentIndex++] = "Frontend";
        if (hasRole(BACKEND_ROLE, account)) roles[currentIndex++] = "Backend";
        if (hasRole(AUTOMATION_ROLE, account)) roles[currentIndex++] = "Automation";
        if (hasRole(AUDITOR_ROLE, account)) roles[currentIndex++] = "Auditor";

        return roles;
    }

    /**
     * @dev Returns a user's account information
     * @param account The address to get information for
     * @return accountNumber The user's account number
     * @return balance The user's gold balance
     * @return roles Array of role names the user has
     */
    function getAccountInfo(address account) public view returns (
        uint256 accountNumber,
        uint256 balance,
        string[] memory roles
    ) {
        return (
            _accountNumbers[account],
            balanceOf(account),
            getRoles(account)
        );
    }

    /**
     * @dev Registers a new account number for an address if it doesn't have one
     * @param account The address to register
     */
    function registerAccount(address account) public {
        require(_accountNumbers[account] == 0, "Account already registered");
        _accountNumbers[account] = _nextAccountNumber++;
        emit AccountRegistered(account, _accountNumbers[account]);
    }

    /**
     * @dev Event emitted when a tip is sent
     */
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

    /**
     * @dev Override the default number of decimals (18) with 0 to enforce whole token amounts
     */
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    /**
     * @dev Allows users to receive a small amount of tokens for free.
     */
    function faucet() public {
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}