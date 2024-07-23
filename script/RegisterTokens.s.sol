// deployAndRegisterTokens.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {UniversalTokenVault} from "../src/UniversalTokenVault.sol";
import {ERC20Test} from "../src/ERC20Test.sol";
import {ERC721Test} from "../src/ERC721Test.sol";
import {ERC1155Test} from "../src/ERC1155Test.sol";

contract RegisterTokens is Script {
    function run(address vaultAddress) external returns (address, address, address) {
        vm.startBroadcast();

        UniversalTokenVault vault = UniversalTokenVault(vaultAddress);

        // Deploy the test ERC20 token contract
        ERC20Test erc20 = new ERC20Test();

        // Activate the ERC20 token in the vault
        vault.activateToken(
            address(erc20),
            true, // hasAmount
            false, // hasId
            erc20.transferFrom.selector, // deposit function signature
            erc20.transferFrom.selector, // withdraw function signature
            0, // from parameter index for deposit 
            1, // to parameter index for deposit 
            2, // amount parameter index for deposit
            0, // id parameter index for deposit (not used)
            0, // from parameter index for withdraw
            1, // to parameter index for withdraw 
            2, // amount parameter index for withdraw
            0  // id parameter index for withdraw (not used)
        );

        // Deploy the test ERC721 token contract
        ERC721Test erc721 = new ERC721Test();

        // Activate the ERC721 token in the vault
        vault.activateToken(
            address(erc721),
            false, // hasAmount
            true, // hasId
            erc721.transferFrom.selector, // deposit function signature
            erc721.transferFrom.selector, // withdraw function signature
            0, // from parameter index for deposit 
            1, // to parameter index for deposit 
            0, // amount parameter index for deposit (not used)
            2, // id parameter index for deposit
            0, // from parameter index for withdraw
            1, // to parameter index for withdraw 
            0, // amount parameter index for withdraw (not used)
            2  // id parameter index for withdraw
        );

        // Deploy the test ERC1155 token contract
        ERC1155Test erc1155 = new ERC1155Test();

        // Activate the ERC1155 token in the vault
        vault.activateToken(
            address(erc1155),
            true, // hasAmount
            true, // hasId
            erc1155.safeTransferFrom.selector, // deposit function signature
            erc1155.safeTransferFrom.selector, // withdraw function signature
            0, // from parameter index for deposit 
            1, // to parameter index for deposit 
            3, // amount parameter index for deposit
            2, // id parameter index for deposit
            0, // from parameter index for withdraw
            1, // to parameter index for withdraw 
            3, // amount parameter index for withdraw
            2  // id parameter index for withdraw
        );

        vm.stopBroadcast();

        return (address(erc20), address(erc721), address(erc1155));
    }
}
