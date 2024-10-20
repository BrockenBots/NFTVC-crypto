// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CertificateVerify is ERC721, Ownable {
    
    enum CertificateStatus {
        Rejected,       
        Pending,        
        Verified       
    }

    struct Certificate {
        uint256 tokenId;
        string data;          
        address issuer;       
        address reviewer;     
        bool isVerified;      
        string pdfLink;       
        bool isPending;  
        CertificateStatus status; 
        }

    mapping(uint256 => Certificate) private certificates; 
    mapping(address => uint256[]) private userCertificates;
    mapping(address => address) private userContracts;
    uint256 private nextTokenId; 

    event CertificateIssued(uint256 indexed tokenId, address indexed issuer, string data, string pdfLink);
    event CertificateVerified(uint256 indexed tokenId);
    event CertificateRejected(uint256 indexed tokenId, string reason);
    mapping(uint256 => address) private certificateAddresses;

    constructor() ERC721("CertificateVerify", "CVT") {
        nextTokenId = 1; 
    }

    function issueCertificate(address to, address reviewer, string memory data, string memory pdfLink) external onlyOwner {
        uint256 tokenId = nextTokenId; 
        certificates[tokenId] = Certificate(tokenId, data, msg.sender, reviewer, false, pdfLink, true, CertificateStatus.Pending);
        userCertificates[to].push(tokenId);
        certificateAddresses[tokenId] = address(this); 

        nextTokenId++; 

        emit CertificateIssued(tokenId, msg.sender, data, pdfLink);
    }

    function verifyAndMintToken(uint256 tokenId) external {
        require(msg.sender == certificates[tokenId].reviewer, "Not authorized to verify");
        require(certificates[tokenId].status == CertificateStatus.Pending, "Certificate not pending");

        certificates[tokenId].isVerified = true; 
        certificates[tokenId].status = CertificateStatus.Verified;

        uint256 newTokenId = nextTokenId;       
        _mint(certificates[tokenId].issuer, newTokenId); 

        emit CertificateVerified(newTokenId);
    }

    function rejectionToken(uint256 tokenId) external {
        require(msg.sender == certificates[tokenId].reviewer, "Not authorized to reject");
        require(certificates[tokenId].status == CertificateStatus.Pending, "Certificate not pending");

        certificates[tokenId].isVerified = false; 
        certificates[tokenId].status = CertificateStatus.Rejected;
        emit CertificateRejected(tokenId, "Certificate has been rejected");
    }

    function getCallerAddress() external view returns (address) {
            return msg.sender; 
        }


    function getUserCertificates(address user) external view returns (Certificate[] memory) {
            uint256[] memory tokenIds = userCertificates[user];
            uint256 length = tokenIds.length;
            
            Certificate[] memory certs = new Certificate[](length);

            for (uint256 i = 0; i < length; i++) {
                certs[i] = certificates[tokenIds[i]]; 
            }

            return certs; 
        }
}

