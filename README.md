# NFT Lending and Borrowing Smart Contract

## Overview

The NFTLending smart contract enables users to lend and borrow using Non-Fungible Tokens (NFTs) as collateral. This Solidity smart contract is built on the Ethereum blockchain and utilizes the ERC721 standard for NFTs and the ERC20 standard for handling loan transactions. Key features include requesting loans, repaying loans, and liquidating defaulted loans.

## Smart Contract Details

### State Variables

1. **`nftToken`**: ERC721 contract instance representing the NFTs used as collateral.
2. **`lendingToken`**: ERC20 contract instance representing the token used for loan transactions.
3. **`loans`**: Mapping to keep track of active loans for each NFT.

### Events

1. **`LoanRequested(address indexed borrower, uint256 tokenId, uint256 amount, uint256 expiry)`**: Emitted when a user requests a loan.
2. **`LoanRepaid(address indexed borrower, uint256 tokenId, uint256 amount)`**: Emitted when a borrower repays their loan.
3. **`LoanDefaulted(uint256 tokenId, address borrower, uint256 amount)`**: Emitted when a loan is defaulted.

### Functions

1. **`requestLoan(uint256 tokenId, uint256 amount, uint256 duration) external`**: Allows NFT owners to request loans against their NFTs.
2. **`repayLoan(uint256 tokenId) external`**: Allows borrowers to repay their loans.
3. **`liquidateDefaultedLoan(uint256 tokenId) external onlyOwner`**: Allows the contract owner to liquidate defaulted loans.

### How to Run

#### Environment Setup

- Set .env environment file as per mentioned in .env.example file.

#### Install Dependencies

- Run `npm install` to install the required dependencies.

### Deploy on Linea Network

- Update the `hardhat.config.js` file with your Linea network configuration.
- Run `npx hardhat run scripts/deploy.js --network <your-network>` to deploy the smart contract (example: `npx hardhat run scripts/deploy.js --network linea_testnet`).
- Run `npx hardhat verify --network linea_testnet <CONTRACT_ADDRESS> {NFT_TOKEN} {LENDING_TOKEN}` to verify the smart contract, and add the INFLURA API key in `.env` file.

