// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EmployeeToken is ERC721, Ownable {
    uint256 private nextTokenId;
    mapping(address => uint256) private employeeToken; // Маппинг для хранения токена работника

    event EmployeeHired(address indexed holder, uint256 indexed tokenId);
    event EmployeeFired(address indexed holder, uint256 indexed tokenId);

    constructor() ERC721("EmployeeToken", "EMP") {
        nextTokenId = 1;
    }

    function hireEmployee(address holder) external onlyOwner {
        uint256 tokenId = nextTokenId;
        _mint(holder, tokenId);
        employeeToken[holder] = tokenId; 
        nextTokenId++;

        emit EmployeeHired(holder, tokenId);
    }

    function fireEmployee(address holder) external onlyOwner {
        require(balanceOf(holder) > 0, "Employee not found");

        uint256 tokenId = employeeToken[holder]; 
        require(tokenId != 0, "No tokens found for this employee");

        _burn(tokenId);
        delete employeeToken[holder];

        emit EmployeeFired(holder, tokenId);
    }
}