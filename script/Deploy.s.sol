// deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {UniversalTokenVault} from "../src/UniversalTokenVault.sol";

contract Deploy is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the UniversalTokenVault contract
        UniversalTokenVault vault = new UniversalTokenVault();
        vault.initialize();
    }
}
