// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CertificateVerify is ERC721, Ownable {
    struct Certificate {
        uint256 tokenId;
        string data;          
        address issuer;       
        address reviewer;     
        bool isVerified;      
        string pdfLink;       
        bool isPending;       
    }

    mapping(uint256 => Certificate) private certificates; 
    uint256 private nextTokenId; // Счетчик для уникальных идентификаторов токенов

    event CertificateIssued(uint256 indexed tokenId, addrQess indexed issuer, string data, string pdfLink);
    event CertificateVerified(uint256 indexed tokenId);
    event CertificateRejected(uint256 indexed tokenId, string reason);
    

    constructor() ERC721("CertificateVerify", "CVT") {
        nextTokenId = 1; 
    }

    // Функция для загрузки сертификата пользователем в лк
    function issueCertificate(address to, address reviewer, string memory data, string memory pdfLink) external onlyOwner {
        uint256 tokenId = nextTokenId; // Уникальный идентификатор для сертификата
        certificates[tokenId] = Certificate(tokenId, data, msg.sender, reviewer, false, pdfLink, true);
        nextTokenId++; 

        emit CertificateIssued(tokenId, msg.sender, data, pdfLink);
    }

    // Функция для подтверждения сертификатов
    function verifyAndMintToken(uint256 tokenId) external {
        require(msg.sender == certificates[tokenId].reviewer, "Not authorized to verify");
        require(certificates[tokenId].isPending, "Certificate not pending");

        certificates[tokenId].isPending = false; 
        certificates[tokenId].isVerified = true; 

        uint256 newTokenId = nextTokenId;       //Создание нфт токена
        _mint(certificates[tokenId].issuer, newTokenId); 

        emit CertificateVerified(newTokenId);
        nextTokenId++; 
    }

    // Функция для отклонения сертификата
    function rejectionToken(uint256 tokenId) external {
        require(msg.sender == certificates[tokenId].reviewer, "Not authorized to reject");
        require(certificates[tokenId].isPending, "Certificate not pending");

        // Логика отклонения сертификата
        certificates[tokenId].isPending = false; 
        certificates[tokenId].isVerified = false; 

        // Эмитируем событие с указанием причины
        emit CertificateRejected(tokenId, "Certificate has been rejected");
    }

    // Функция для получения информации о сертификате
    function getCertificate(uint256 tokenId) external view returns (Certificate memory) {
        return certificates[tokenId];
    }
}