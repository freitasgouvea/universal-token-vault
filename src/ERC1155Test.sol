// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ERC1155 } from "../lib/solmate/src/tokens/ERC1155.sol";
import { Owned } from "../lib/solmate/src/auth/Owned.sol";

contract ERC1155Test is ERC1155, Owned {
    constructor() ERC1155() Owned(msg.sender) {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(to, id, amount, data);
    }

    function burn(address account, uint256 id, uint256 amount) public {
        require(msg.sender == account, "UNAUTHORIZED");
        _burn(account, id, amount);
    }

    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {}
}
