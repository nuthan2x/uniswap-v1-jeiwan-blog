//SPDX-License-Identifier : UNLICENSED
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{
    constructor(string memory name, string memory symbol, address mintTo, uint256 initialSupply) ERC20(name, symbol) {
        _mint(mintTo, initialSupply);
    }
}