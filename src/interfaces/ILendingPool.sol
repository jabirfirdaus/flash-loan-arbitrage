// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingPool {
    function flashLoan(address receiver, uint256 amount) external;
}