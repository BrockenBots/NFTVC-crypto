// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Verify is ERC721 {
    constructor() ERC721("Verify", "MTK") {}
    // uint256 public huy;

    // function set(uint256 _huy) public {
    //     huy = _huy;
    // }
}

// verify recall date - verify creation date = stacking