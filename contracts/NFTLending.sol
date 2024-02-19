// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTLending is Ownable, ERC721Holder {
    using SafeMath for uint256;

    // ERC721 token representing NFTs
    IERC721 public nftToken;

    // ERC20 token used for handling loan transactions
    IERC20 public lendingToken;

    // Mapping to keep track of active loans for each NFT
    mapping(uint256 => Loan) public loans;

    // Structure defining a loan
    struct Loan {
        uint256 amount;    // Loan amount
        uint256 expiry;    // Loan expiry timestamp
        address borrower;  // Borrower's address
        bool active;       // Flag indicating whether the loan is active
    }

    // Events to log loan-related actions
    event LoanRequested(address indexed borrower, uint256 tokenId, uint256 amount, uint256 expiry);
    event LoanRepaid(address indexed borrower, uint256 tokenId, uint256 amount);
    event LoanDefaulted(uint256 tokenId, address borrower, uint256 amount);

    // Constructor to set the addresses of ERC721 and ERC20 tokens
    constructor(address _nftToken, address _lendingToken) {
        nftToken = IERC721(_nftToken);
        lendingToken = IERC20(_lendingToken);
    }

    // Function to request a loan against an NFT
    function requestLoan(uint256 tokenId, uint256 amount, uint256 duration) external {
        require(!loans[tokenId].active, "NFT already used as collateral");
        require(nftToken.ownerOf(tokenId) == msg.sender, "You are not the owner of the NFT");
        require(nftToken.getApproved(tokenId) == address(this), "Contract address is not approved by owner");

        // Create a new loan
        loans[tokenId] = Loan({
            amount: amount,
            expiry: block.timestamp.add(duration),
            borrower: msg.sender,
            active: true
        });

        // Transfer loan amount from contract owner to the borrower
        lendingToken.transferFrom(owner(), msg.sender, amount);

        // Emit LoanRequested event
        emit LoanRequested(msg.sender, tokenId, amount, loans[tokenId].expiry);
    }

    // Function for borrowers to repay their loans
    function repayLoan(uint256 tokenId) external {
        require(loans[tokenId].borrower == msg.sender, "You are not the borrower of this loan");
        require(loans[tokenId].active, "No loan exists for this NFT");
        require(block.timestamp <= loans[tokenId].expiry, "Loan has expired");

        // Retrieve the loan amount
        uint256 amount = loans[tokenId].amount;

        // Deactivate the loan
        loans[tokenId].active = false;

        // Transfer loan amount from borrower to contract owner
        lendingToken.transfer(owner(), amount);

        // Emit LoanRepaid event
        emit LoanRepaid(msg.sender, tokenId, amount);
    }

    // Function for the contract owner to liquidate defaulted loans
    function liquidateDefaultedLoan(uint256 tokenId) external onlyOwner {
        require(loans[tokenId].active && block.timestamp > loans[tokenId].expiry, "Loan not defaulted");

        // Retrieve loan details
        uint256 amount = loans[tokenId].amount;
        address borrower = loans[tokenId].borrower;

        // Deactivate the loan
        loans[tokenId].active = false;

        // Transfer NFT ownership to the contract owner (liquidator)
        nftToken.safeTransferFrom(borrower, owner(), tokenId);

        // Transfer collateral (loan amount) to the contract owner (liquidator)
        lendingToken.transfer(owner(), amount);

        // Emit LoanDefaulted event
        emit LoanDefaulted(tokenId, borrower, amount);
    }
}
