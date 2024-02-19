// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTLending is Ownable {
    // ERC721 token contract
    IERC721 public nft;

    // mapping to keep track of active loans for each NFT
    mapping(uint256 => Loan) public loans;

    // constant for the minimum loan amount
    uint256 public constant MIN_LOAN_AMOUNT = 1 ether;

    // constant for the maximum loan duration in days
    uint256 public constant MAX_LOAN_DURATION = 365 days;

    // constant for the interest rate in percentage points
    uint256 public constant INTEREST_RATE = 5;

    // struct to represent a loan
    struct Loan {
        address borrower; // The borrower's address
        uint256 amount; // The loan amount
        uint256 deadline; // The deadline for repayment
        bool repaid; // A flag to indicate if the loan has been repaid
    }

    // Event is emitted when a loan is created
    event LoanCreated(uint256 tokenId, uint256 amount, uint256 duration, address borrower);

    // Event is emitted when an NFT is borrowed
    event NFTBorrowed(uint256 tokenId, address borrower);

    // Event is emitted when a loan is repaid
    event LoanRepaid(uint256 tokenId, address borrower, uint256 amount);

    // Event is emitted when an NFT is withdrawn from the contract
    event NFTWithdrawn(uint256 tokenId);

    // constructor to initialize the contract with the ERC721 token address
    constructor(IERC721 _nft) {
        nft = _nft;
    }

    // Function to enable the owner to lend an NFT with a specified amount and duration
    function lend(uint256 tokenId, uint256 amount, uint256 duration) external onlyOwner {
        // Check if the amount is at least the minimum loan amount
        require(amount >= MIN_LOAN_AMOUNT, "Amount must be at least the minimum loan amount");

        // Check if the duration is less than or equal to the maximum loan duration
        require(duration <= MAX_LOAN_DURATION, "Duration must be less than or equal to the maximum loan duration");

        // Create a new loan with the borrower as the zero address
        Loan storage loan = loans[tokenId];
        loan.borrower = address(0);
        loan.amount = amount;
        loan.deadline = block.timestamp + duration;
        loan.repaid = false;

        // Emit an event to indicate that a loan has been created
        emit LoanCreated(tokenId, amount, duration, address(0));
    }

    // Function to enable a user to borrow an NFT if it's available for borrowing
    function borrow(uint256 tokenId) external {
        // Get the loan for the NFT
        Loan storage loan = loans[tokenId];

        // Check if the NFT is available for borrowing
        require(loan.borrower == address(0), "This NFT is not available for borrowing");

        // Check if the NFT is available for borrowing before the deadline
        require(block.timestamp < loan.deadline, "This NFT is no longer available for borrowing");

        // Transfer the NFT to the borrower
        nft.transferFrom(owner(), msg.sender, tokenId);

        // Set the borrower for the NFT
        loan.borrower = msg.sender;

        // Emit an event to indicate that the NFT has been borrowed
        emit NFTBorrowed(tokenId, msg.sender);
    }

       // Function to repay a loan
    function repay(uint256 tokenId) external {
        // Get the loan for the NFT
        Loan storage loan = loans[tokenId];

        // Check if the borrower is repaying their own loan
        require(loan.borrower == msg.sender, "You are not the borrower of this NFT");

        // Check if the loan has not been repaid yet
        require(!loan.repaid, "You have already repaid this loan");

        // Check if the loan has not expired
        require(block.timestamp <= loan.deadline, "The loan has expired");

        // Calculate the interest amount
        uint256 interest = (loan.amount * INTEREST_RATE) / 100 * (block.timestamp - loan.deadline);

        // Transfer the repayment amount (principal + interest) to the owner
        payable(owner()).transfer(loan.amount.add(interest));

        // Set the loan as repaid
        loan.repaid = true;

        // Emit the LoanRepaid event
        emit LoanRepaid(tokenId, msg.sender, loan.amount.add(interest));
    }

    // Function to withdraw an NFT from the contract
    function withdraw(uint256 tokenId) external onlyOwner {
        // Check if the NFT is currently borrowed
        require(loans[tokenId].borrower == address(0), "This NFT is currently borrowed");

        // Check if the loan has been repaid
        require(loans[tokenId].repaid, "The borrower has not yet repaid the loan");

        // Transfer the NFT back to the owner
        nft.transferFrom(msg.sender, owner(), tokenId);

        // Emit the NFTWithdrawn event
        emit NFTWithdrawn(tokenId);

        // Delete the loan information for the NFT
        delete loans[tokenId];
    }
}