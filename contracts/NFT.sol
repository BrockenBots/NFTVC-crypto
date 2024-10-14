// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    constructor() ERC721("NFT", "MTK") {}
    // uint256 public huy;

    // function set(uint256 _huy) public {
    //     huy = _huy;
    // }
}

// modifier stacking