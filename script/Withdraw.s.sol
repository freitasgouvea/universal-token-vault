// withdrawTokens.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {UniversalTokenVault} from "../src/UniversalTokenVault.sol";
import {ERC20Test} from "../src/ERC20Test.sol";
import {ERC721Test} from "../src/ERC721Test.sol";
import {ERC1155Test} from "../src/ERC1155Test.sol";

contract Withdraw is Script {
    function run(
      address vaultAddress, 
      address erc20Address, 
      address erc721Address, 
      address erc1155Address
    ) external returns (uint256, address, uint256) {
        vm.startBroadcast();

        UniversalTokenVault vault = UniversalTokenVault(vaultAddress);
        ERC20Test erc20 = ERC20Test(erc20Address);
        ERC721Test erc721 = ERC721Test(erc721Address);
        ERC1155Test erc1155 = ERC1155Test(erc1155Address);

        // Withdraw ERC20
        bytes memory dataERC20 = abi.encodeWithSelector(ERC20Test(erc20Address).transfer.selector, vaultAddress, msg.sender, 100000);
        vault.withdraw(address(erc20), dataERC20);

        // Withdraw ERC721
        bytes memory dataERC721 = abi.encodeWithSelector(erc721.transferFrom.selector, vaultAddress, msg.sender, 1);
        vault.withdraw(address(erc721), dataERC721);

        // Withdraw ERC1155
        bytes memory dataERC1155 = abi.encodeWithSelector(erc1155.safeTransferFrom.selector, vaultAddress, msg.sender, 1, 1000, "");
        vault.withdraw(address(erc1155), dataERC1155);

        vm.stopBroadcast();

        // Output balances
        uint256 erc20Balance = vault.getUserTokenBalance(msg.sender, address(erc20));
        address erc721Balance = vault.getOwnerOfTokenId(address(erc721), 1);
        uint256 erc1155Balance = vault.getUserBalanceOfTokenId(msg.sender, address(erc1155), 1);

        return (erc20Balance, erc721Balance, erc1155Balance);
    }
}
