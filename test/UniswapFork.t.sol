// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract UniswapForkTest is Test {
    IUniswapV2Router router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IERC20 weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    function setUp() public {
        deal(address(weth), address(this), 10 ether);
    }

    function test_SwapWethKeDai() public {
        console.log("Saldo WETH Awal:", weth.balanceOf(address(this)));
        console.log("Saldo DAI Awal :", dai.balanceOf(address(this)));

        weth.approve(address(router), 1 ether);

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(dai);

        router.swapExactTokensForTokens(
            1 ether,
            0,
            path,
            address(this),
            block.timestamp + 300
        );

        console.log("Saldo WETH Akhir:", weth.balanceOf(address(this)));
        console.log("Saldo DAI Akhir :", dai.balanceOf(address(this)));
    }
}