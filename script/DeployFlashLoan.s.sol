// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/FlashLoanArbitrage.sol";

contract DeployFlashLoan is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        address poolAddress = 0x0000000000000000000000000000000000000001;
        address routerAddress = 0x0000000000000000000000000000000000000002;
        address tokenAddress = 0x0000000000000000000000000000000000000003;

        FlashLoanArbitrage bot = new FlashLoanArbitrage(poolAddress, routerAddress, tokenAddress);

        vm.stopBroadcast();
    }
}