## Uniswap V1

**A simplified Solidity implementation of Uniswap V1 - an automated liquidity protocol.**
This project implements a basic AMM (Automated Market Maker) for token-ETH trading pairs with:
- **Constant Product Formula**: x * y = k
- **0.3% Trading Fee**: Applied on all swaps
- wrote with help of https://github.com/Jeiwan/zuniswap/

## Contracts

### Factory.sol
- `createExchange(address token)`: Creates a new token-ETH exchange pair

### Exchange.sol

**Liquidity:**
- `addLiquidity(uint256 tokenAmount) external payable`: Add liquidity and mint LP tokens
- `removeLiquidity(uint256 burnAmount)`: Remove liquidity and burn LP tokens

**Swaps:**
- `ethToTokenSwap(uint256 minOut)`: Swap ETH for tokens
- `tokenToEth(uint256 tokensSold, uint256 minETHOut)`: Swap tokens for ETH
- `tokenToTokenSwap(uint256 amountIn, uint256 minTokenOutAmount, address tokenOutAddress)`: Direct token-to-token swap

**Pricing:**
- `getTokenOut(uint256 ethAmountIn)`: Get expected token output for ETH input
- `getETHOut(uint256 tokenAmountIn)`: Get expected ETH output for token input
- `getAmountOut(uint256 amountIn, uint256 assetInReserve, uint256 assetOutReserve)`: Core pricing formula

## Usage

### Build

```shell
$ forge build
```
