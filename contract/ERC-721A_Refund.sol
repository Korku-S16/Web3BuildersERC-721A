// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

// Import ERC721A implementation (optimized NFT standard)
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
// Import interface for ERC721R (if needed in future)
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";
// Import OpenZeppelin's Ownable contract for access control
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Web3Builders NFT Contract with Refund Mechanism
/// @author 
/// @notice This contract allows minting NFTs with a refund window per token
/// @dev Uses ERC721A for gas optimized batch minting, includes refund period, ownership tracking and secure payout
contract Web3Builders is ERC721A, Ownable {
    // Fixed price per NFT
    uint256 public constant MintPrice = 1 ether;
    // Max NFTs a single user can mint
    uint public constant maxmintedperUser = 3;
    // Overall maximum NFTs available
    uint256 public maxMintsupply = 100;
    
    // Refund duration window (3 minutes here)
    uint256 public constant refundPeriod = 3 minutes;
    // Global refund window end timestamp of last minted NFT
    uint256 public refundEndTimestamp;

    // Address where refunded NFTs are held (owner contract itself)
    address public refundAddress;

    // Mapping to store refund deadline for each tokenId
    mapping(uint256 => uint256) public refundEndTimestamps; 
    // Track which tokens have already been refunded, prevents double refund
    mapping(uint256 => bool) public hasRefunded;

    /// @notice Contract constructor initializing ERC721A and Ownable
    /// @param initialOwner Owner of the contract for administrative functions
    constructor(address initialOwner)
        ERC721A("Web3Builders", "WE3")
        Ownable(initialOwner)
    {
        refundAddress = address(this); // Set self as refund holder
        refundEndTimestamp = block.timestamp + refundPeriod; // Initialize global refund window
    }

    /// @notice Base URI for token metadata (IPFS URI)
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/";
    }

    /// @notice Mint NFTs by paying the required ether amount
    /// @param quantity Number of NFTs to mint
    /// Requirements:
    /// - Sent ether must be at least MintPrice * quantity
    /// - User cannot mint more than maxmintedperUser in total
    /// - Total minted supply must not exceed maxMintsupply
    /// Effects:
    /// - Mints quantity NFTs to msg.sender
    /// - Sets refund deadline individually for each minted token
    function safeMint(uint256 quantity) public payable {
        require(msg.value >= quantity * MintPrice, "Incorrect value sent");
        require(_numberMinted(msg.sender) + quantity <= maxmintedperUser, "You can not mint more than 3 NFTs");
        require(_totalMinted() + quantity <= maxMintsupply, "Sold Out");
        
        // Batch mint NFTs to msg.sender
        _safeMint(msg.sender, quantity);
        
        // Update global refund end timestamp to current time + refundPeriod
        refundEndTimestamp = block.timestamp + refundPeriod;
        
        // For each newly minted tokenId, set individual refund deadline
        for (uint256 i = _currentIndex - quantity; i < _currentIndex; i++) {
            refundEndTimestamps[i] = refundEndTimestamp;
        }
    }


    /// @notice Refund the NFT within refund window and get back the mint price
    /// @param tokenId The ID of the token to refund
    /// Requirements:
    /// - Function caller must be owner of the token
    /// - Refund period must not have ended for the token
    /// Effects:
    /// - Transfers NFT ownership from user to contract
    /// - Marks token as refunded to prevent double refund
    /// - Sends refund amount (mint price) to token owner
    function refund(uint256 tokenId) external {
        require(block.timestamp < getRefundDeadline(tokenId), "Refund period has ended");
        require(msg.sender == ownerOf(tokenId), "Only the owner of the token can refund");
        
        // Calculate refund amount (zero if already refunded)
        uint256 refundAmount = getRefundAmount(tokenId);

        // Transfer NFT ownership back to contract for refund management
        _transfer(msg.sender, refundAddress, tokenId);
        
        // Mark the token as refunded so it cannot be refunded twice
        hasRefunded[tokenId] = true;
        
        // Send refund Ether securely to the user
        Address.sendValue(payable(msg.sender), refundAmount);
    }

    /// @notice Returns the refund deadline timestamp for a token
    /// @param tokenId The token ID to query
    /// @return Refund deadline timestamp or 0 if already refunded
    function getRefundDeadline(uint256 tokenId) public view returns(uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndTimestamps[tokenId];
    }

    /// @notice Returns the refund amount for a token (zero if already refunded)
    /// @param tokenId The token ID to query
    /// @return Refund amount in wei
    function getRefundAmount(uint256 tokenId) public view returns(uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return MintPrice;
    }

    /// @notice Allows contract owner to withdraw contract balance after refund periods have ended
    /// Requirements:
    /// - Global refund period must have ended (refund window for last minted token)
    /// Effects:
    /// - Transfers full contract ETH balance to owner
    function withdraw() external onlyOwner {
        require(block.timestamp > refundEndTimestamp, "Refund period has not ended");
        uint256 balance = address(this).balance;
        Address.sendValue(payable(msg.sender), balance);
    }
}
