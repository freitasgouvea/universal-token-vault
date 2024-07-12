// deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {UniversalTokenVault} from "../src/UniversalTokenVault.sol";
import {ERC20Test} from "../src/ERC20Test.sol";
import {ERC721Test} from "../src/ERC721Test.sol";
import {ERC1155Test} from "../src/ERC1155Test.sol";

contract DeployAndTest is Script {
    function run() external returns (uint256, address, uint256) {
        address testWalletAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the UniversalTokenVault contract
        UniversalTokenVault vault = new UniversalTokenVault();
        vault.initialize();

        // Deploy the test ERC20 token contract
        ERC20Test erc20 = new ERC20Test();

        // Activate the ERC20 token in the vault
        vault.activateToken(
            address(erc20),
            true, // hasAmount
            false, // hasId
            erc20.transferFrom.selector, // deposit function signature
            erc20.transfer.selector, // withdraw function signature
            1, // amount parameter index for deposit
            0, // id parameter index for deposit (not used)
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
            0, // amount parameter index for deposit (not used)
            1, // id parameter index for deposit
            0, // amount parameter index for withdraw (not used)
            1  // id parameter index for withdraw
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
            3, // amount parameter index for deposit
            2, // id parameter index for deposit
            3, // amount parameter index for withdraw
            2  // id parameter index for withdraw
        );

        // Test ERC20 deposit
        erc20.mint(testWalletAddress, 100000);
        erc20.approve(address(vault), 100000);
        bytes memory dataERC20 = abi.encodeWithSelector(
            erc20.transferFrom.selector,
            testWalletAddress, // sender
            address(vault), // recipient
            100000 // amount
        );
        vault.deposit(address(erc20), dataERC20);

        // Test ERC721 deposit
        erc721.mint(testWalletAddress, 1);
        erc721.setApprovalForAll(address(vault), true);
        bytes memory dataERC721 = abi.encodeWithSelector(
            erc721.transferFrom.selector,
            testWalletAddress, // sender
            address(vault), // recipient
            1 // tokenId
        );
        vault.deposit(address(erc721), dataERC721);

        // Test ERC1155 deposit
        erc1155.mint(testWalletAddress, 1, 1000, '');
        erc1155.setApprovalForAll(address(vault), true);
        bytes memory dataERC1155 = abi.encodeWithSelector(
            erc1155.safeTransferFrom.selector,
            testWalletAddress, // sender
            address(vault), // recipient
            1, // tokenId
            1000, // amount
            "" // data
        );
        vault.deposit(address(erc1155), dataERC1155);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Return the balances and ownerships
        uint256 erc20Balance = vault.getUserTokenBalance(testWalletAddress, address(erc20));
        address erc721Owner = vault.getOwnerOfTokenId(address(erc721), 1);
        uint256 erc1155Balance = vault.getUserBalanceOfTokenId(testWalletAddress, address(erc1155), 1);

        return (erc20Balance, erc721Owner, erc1155Balance);
    }
}
