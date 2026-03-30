// SPDX-License-Identifier : UNLICENSED
pragma solidity ^0.8.0;

import "./Token.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

interface IFactory{
    function tokenExchange(address token) public view returns(address);
}

contract Exchange is ERC20 {
    using SafeERC20 for IERC20;

    address public factory;
    address public token;

    constructor(address _token) ERC20(
        string.concat(IERC20Metadata(_token).name(), "-ETH LP"), 
        string.concat(IERC20Metadata(_token).symbol(),"-ETH")
    ) {
        require(_token != address(0), "invalid token address");
        token = _token;

        factory = msg.sender;
    }

    /* @audit is eth share based lp minting right? do the btt in both cases, 
        if` price pump dump same `: all 3 cases work with different reserves correctly.., 
    */
    function addLiquidity(uint256 tokenAmount) external payable returns(uint256 liquidity){
        if (getReserve() == 0) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAmount);
            // @audit what if 0 eth sent in or 0 token sent in ?

            uint256 liquidity = address(this).balance;
            _mint(msg.sender, liquidity);

            return liquidity;
        } else {
            uint256 oldEthReserve = address(this).balance - msg.value;
            uint256 tokenAccepted = msg.value * getReserve() / oldEthReserve;
            require(tokenAmount >= tokenAccepted);

            IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAccepted);

            uint256 liquidity = msg.value * _totalSupply / oldEthReserve;
            _mint(msg.sender, liquidity);

            return liquidity;
        }
    }

    function removeLiquidity(uint256 burnAmount) external returns(uint256, uint256){
        require(burnAmount > 0);

        uint256 tokenOut = burnAmount * getReserve() / _totalSupply;
        uint256 ethOut = burnAmount * address(this).balance / _totalSupply;

        _burn(msg.sender, burnAmount);

        IERC20(token).safeTransfer(msg.sender, tokenOut);
        payable(msg.sender).transfer(ethOut);

        return(ethOut, tokenOut);
    }

    function tokenToTokenSwap(
        uint256 amountIn,
        uint256 minTokenOutAmount,
        address tokenOutAddress
    ) external {
        address exchangeOut = IFactory(factory).tokenExchange(tokenOutAddress);
        require(
            exchangeOut != address(this) && exchangeOut != address(0)
        );

        uint256 ethOut = getAmountOut(tokensSold, getReserve(), address(this).balance);
        IERC20(token).safeTransferFrom(msg.sender, address(this), tokensSold);
        
        Exchange(exchangeOut).ethToToken{value : ethOut}(minTokenOutAmount, msg.sender);
    }


    function ethToToken(uint256 minOut, address recipient) external payable {
        _ethToToken(minOut, recipient);
    }
    
    function ethToTokenSwap(uint256 minOut) external payable {
        _ethToToken(minOut, msg.sender);
    }

    function _ethToToken(uint256 minOut, address recipient) private {
        uint256 ethReserve = address(this).balance - msg.value;

        uint256 tokenAmountout = getAmountOut(msg.value, ethReserve, getReserve());
        require(tokenAmountout >= minOut);

        IERC20(token).safeTransfer(msg.sender, tokenAmountout);
    }

    function tokenToEth(uint256 tokensSold, uint256 minETHOut) external {
        uint256 ethOut = getAmountOut(tokensSold, getReserve(), address(this).balance);
        require(ethOut >= minETHOut);

        IERC20(token).safeTransferFrom(msg.sender, address(this), tokensSold);
        payable(msg.sender).transfer(ethOut);
    }

    function getReserve() public view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function getETHOut(uint256 tokenAmountIn) public view returns(uint256){
        require(tokenAmountIn > 0, "invalid tokenAmountIn");
        return getAmountOut(tokenAmountIn, getReserve(), address(this).balance);
    }

    function getTokenOut(uint256 ethAmountIn) public view returns(uint256) {
        require(ethAmountIn > 0, "invalid ethAmountIn");
        return getAmountOut(ethAmountIn, address(this).balance, getReserve());
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 assetInReserve,
        uint256 assetOutReserve
    ) private pure returns(uint256){
        require(assetInReserve > 0 && assetOutReserve > 0, "invalid reserves");

        uint256 amountInWithFee = amountIn * 997 / 1000;
        return assetOutReserve * amountInWithFee / (assetInReserve + amountInWithFee);
    }

}