// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ERC721 } from "../lib/solmate/src/tokens/ERC721.sol";
import { Owned } from "../lib/solmate/src/auth/Owned.sol";

contract ERC721Test is ERC721, Owned {
    constructor() ERC721("ERC721Test", "T721") Owned(msg.sender) {}

    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "UNAUTHORIZED");
        _burn(tokenId);
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {}
}
