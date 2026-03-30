// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "./Exchange.sol";

contract Factory {
    mapping(address token => address exchange) public tokenExchange;

    function createExchange(address token) external returns(address) {
        require(token != address(0));
        require(tokenExchange[token] == address(0));

        Exchange exchange = new Exchange(token);
        tokenExchange[token] = address(exchange);

        return address(exchange);
    }
    
}
