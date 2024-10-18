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
    uint256 private nextTokenId; 

    event CertificateIssued(uint256 indexed tokenId, address indexed issuer, string data, string pdfLink);
    event CertificateVerified(uint256 indexed tokenId);
    event CertificateRejected(uint256 indexed tokenId, string reason);
    

    constructor() ERC721("CertificateVerify", "CVT") {
        nextTokenId = 1; 
    }

    function issueCertificate(address to, address reviewer, string memory data, string memory pdfLink) external onlyOwner {
        uint256 tokenId = nextTokenId; 
        certificates[tokenId] = Certificate(tokenId, data, msg.sender, reviewer, false, pdfLink, true);
        nextTokenId++; 

        emit CertificateIssued(tokenId, msg.sender, data, pdfLink);
    }

    function verifyAndMintToken(uint256 tokenId) external {
        require(msg.sender == certificates[tokenId].reviewer, "Not authorized to verify");
        require(certificates[tokenId].isPending, "Certificate not pending");

        certificates[tokenId].isPending = false; 
        certificates[tokenId].isVerified = true; 

        uint256 newTokenId = nextTokenId;       
        _mint(certificates[tokenId].issuer, newTokenId); 

        emit CertificateVerified(newTokenId);
        nextTokenId++; 
    }

    function rejectionToken(uint256 tokenId) external {
        require(msg.sender == certificates[tokenId].reviewer, "Not authorized to reject");
        require(certificates[tokenId].isPending, "Certificate not pending");

        certificates[tokenId].isPending = false; 
        certificates[tokenId].isVerified = false; 

        emit CertificateRejected(tokenId, "Certificate has been rejected");
    }

    function getCertificate(uint256 tokenId) external view returns (Certificate memory) {
        return certificates[tokenId];
    }
}