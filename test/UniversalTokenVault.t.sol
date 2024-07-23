// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test, console2 } from "forge-std/Test.sol";

import "forge-std/Test.sol";

import { ERC20Test } from "../src/ERC20Test.sol";
import {ERC721Test} from "../src/ERC721Test.sol";
import {ERC1155Test} from "../src/ERC1155Test.sol";
import { UniversalTokenVault } from "../src/UniversalTokenVault.sol";

interface Events {
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract UniversalTokenVaultTest is Test, Events {
    ERC20Test public erc20;
    ERC721Test public erc721;
    ERC1155Test public erc1155;
    UniversalTokenVault public vault;

    address owner = address(0x123);
    address alice = address(0x456);
    address bob = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        vault = new UniversalTokenVault();
        vault.initialize();

        erc20 = new ERC20Test();

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
        erc721 = new ERC721Test();

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
        erc1155 = new ERC1155Test();

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

        erc20.mint(alice, UINT256_MAX);

        for (uint i = 1; i < 4; i++) {
            erc721.mint(alice, i);
        }

        erc1155.mint(alice, 1, UINT256_MAX, "");

        vm.stopPrank();
    }

    function test_Deposit(uint256 amount) public {
        if(amount == 0) {
            amount = 100;
        }

        vm.startPrank(alice);

        erc20.approve(address(vault), amount);
        erc721.setApprovalForAll(address(vault), true);
        erc1155.setApprovalForAll(address(vault), true);
        
        vm.expectEmit();
        emit Transfer(address(alice), address(vault), amount);
        bytes memory dataERC20 = abi.encodeWithSelector(
            erc20.transferFrom.selector, 
            address(alice), 
            address(vault), 
            amount
        );
        vault.deposit(address(erc20), dataERC20);

        bytes memory dataERC721 = abi.encodeWithSelector(
            erc721.transferFrom.selector, 
            address(alice), 
            address(vault), 
            1
        );
        vault.deposit(address(erc721), dataERC721);

        bytes memory dataERC1155 = abi.encodeWithSelector(
            erc1155.safeTransferFrom.selector, 
            address(alice), 
            address(vault), 
            1, 
            amount, 
            ""
        );
        vault.deposit(address(erc1155), dataERC1155);

        vm.stopPrank();

        assertEq(erc20.balanceOf(address(vault)), amount);
        assertEq(vault.getUserTokenBalance(address(alice), address(erc20)), amount);

        assertEq(erc721.balanceOf(address(vault)), 1);
        assertEq(vault.getOwnerOfTokenId(address(erc721), 1), address(alice));
        
        assertEq(erc1155.balanceOf(address(vault), 1), amount);
        assertEq(vault.getUserBalanceOfTokenId(address(alice), address(erc1155), 1), amount);
    }

    function test_Withdraw(uint256 amount) public {
        if(amount == 0) {
            amount = 100;
        }

        test_Deposit(amount);

        vm.startPrank(alice);

        erc20.approve(address(vault), amount);
        erc721.setApprovalForAll(address(vault), true);
        erc1155.setApprovalForAll(address(vault), true);
        

        // Withdraw ERC20
        bytes memory dataERC20 = abi.encodeWithSelector(
            erc20.transferFrom.selector, 
            address(vault),
            address(alice), 
            amount
        );
        vault.withdraw(address(erc20), dataERC20);

        // Withdraw ERC721
        bytes memory dataERC721 = abi.encodeWithSelector(
            erc721.transferFrom.selector, 
            address(vault), 
            address(alice), 
            1
        );
        vault.withdraw(address(erc721), dataERC721);

        // Withdraw ERC1155
        bytes memory dataERC1155 = abi.encodeWithSelector(
            erc1155.safeTransferFrom.selector, 
            address(vault), 
            address(alice), 
            1, 
            amount, 
            ""
        );
        vault.withdraw(address(erc1155), dataERC1155);

        vm.stopPrank();

        assertEq(erc20.balanceOf(address(alice)), UINT256_MAX);
        assertEq(vault.getUserTokenBalance(address(alice), address(erc20)), 0);

        assertEq(erc721.balanceOf(address(alice)), 3);
        assertEq(vault.getOwnerOfTokenId(address(erc721), 1), address(0));
        
        assertEq(erc1155.balanceOf(address(alice), 1), UINT256_MAX);
        assertEq(vault.getUserBalanceOfTokenId(address(alice), address(erc1155), 1), 0);
    }
}
