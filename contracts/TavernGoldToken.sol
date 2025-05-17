// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TavernGoldToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Tavern Gold", "TGLD") {
        _mint(msg.sender, initialSupply);
    }
} 