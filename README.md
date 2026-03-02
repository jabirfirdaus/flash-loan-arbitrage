# ⚡ DeFi Flash Loan Arbitrage Bot & Gas Optimization Sandbox

A professional-grade sandbox environment demonstrating advanced EVM capabilities, including Decentralized Finance (DeFi) Flash Loan mechanics and extreme gas optimization techniques.

## 🏗️ Architecture & Features

This repository is divided into two core technical demonstrations:

### 1. Flash Loan Arbitrage Implementation

Demonstrates how to borrow uncollateralized assets from a lending pool, execute trades across multiple Decentralized Exchanges (DEXs), and repay the loan within a single transaction block.

- **Mainnet Forking:** Utilizes Foundry's mainnet fork testing capabilities to interact with real-world protocols (Uniswap V2) safely in a local environment.
- **Interface Segregation:** Adheres to clean architecture by separating `IERC20`, `ILendingPool`, and `IUniswapV2Router` interfaces.
- **Security First:** Implements proper access control (`msg.sender == owner`) and strict profitability checks to ensure transactions revert if the arbitrage fails, protecting against financial loss.

### 2. EVM Gas Optimization (Storage Packing)

Demonstrates deep understanding of Ethereum Virtual Machine (EVM) storage slots and opcode costs.

- **Struct Data Packing:** Reduces gas consumption significantly by packing multiple smaller data types (`uint128`) into a single 32-byte storage slot, minimizing expensive `SSTORE` operations.
- **Gas Reporting:** Includes comprehensive Foundry gas reports proving the mathematical efficiency of the packed structures versus unoptimized storage.

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) installed on your local machine.

### Installation

1. Clone the repository:

   ```bash
   git clone [https://github.com/jabirfirdaus/flash-loan-arbitrage](https://github.com/jabirfirdaus/flash-loan-arbitrage)
   cd flash-loan-bot

   ```

2. Install dependencies:
   Bash
   forge install

3. Set up your environment variables:
   Create a .env file in the root directory and add a mock private key and an RPC URL:
   PRIVATE_KEY=your_mock_private_key
   RPC_URL=[https://ethereum.publicnode.com](https://ethereum.publicnode.com)

Testing & Execution
Run Gas Optimization Tests:
forge test --match-contract StorageMeter --gas-report

    Run Mainnet Fork Flash Loan Simulation:
    forge test --match-path test/UniswapFork.t.sol -vv --fork-url $RPC_URL

📜 Disclaimer
This project is strictly for educational and portfolio demonstration purposes. The smart contracts have not been audited. Do not use them in production with real funds without proper modification and professional auditing.
