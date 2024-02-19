# Overview
The NFTLending smart contract enables users to lend and borrow using Non-Fungible Tokens (NFTs) as collateral. This Solidity smart contract is built on the Ethereum blockchain and utilizes the ERC721 standard for NFTs and the ERC20 standard for handling loan transactions. Key features include requesting loans, repaying loans, and liquidating defaulted loans.

## Smart Contract Details
### State Variables
1. `nft`: ERC721 contract instance representing the NFTs used as collateral.
2. `minLoanAmount`: The minimum loan amount required to borrow an NFT.
3. `maxLoanDuration`: The maximum loan duration for borrowing an NFT.
4. `interestRate`: The interest rate for loan transactions.
5. `loans`: Mapping to keep track of active loans for each NFT and borrower.
6. `defaultedLoans`: Mapping to keep track of defaulted loans.

### Events
1. `LoanRequested(address indexed borrower, uint256 tokenId, uint256 amount, uint256 expiry)`: Emitted when a user requests a loan.
2. `LoanRepaid(address indexed borrower, uint256 tokenId, uint256 amount)`: Emitted when a borrower repays their loan.
3. `LoanDefaulted(uint256 tokenId, address borrower, uint256 amount)`: Emitted when a loan is defaulted.

## Functions
1. `constructor(address nftAddress)`: Initializes the smart contract with the NFT contract address.
2. `lend(uint256 tokenId, uint256 amount, uint256 duration) external`: Allows NFT owners to lend their NFT and receive loan repayments.
3. `borrow(uint256 tokenId, uint256 amount, uint256 duration) external`: Allows users to borrow an NFT by providing a loan.
4. `repay(uint256 tokenId) external`: Allows borrowers to repay their loans.
5. `liquidateDefaultedLoan(uint256 tokenId) external onlyOwner`: Allows the contract owner to liquidate defaulted loans.

## How to Run
### Environment Setup
1. Set `.env` environment file as per mentioned in `.env.example` file.

### Install Dependencies
1. Run `npm install` to install the required dependencies.

## Deploy on Linea Network
1. Update the hardhat.config.js file with your Linea network configuration.
2. Run `npx hardhat run scripts/deploy.js --network <your-network>` to deploy the smart contract (example: npx hardhat run scripts/deploy.js --network linea_testnet).
3. Run `npx hardhat verify --network linea_testnet <CONTRACT_ADDRESS> {NFT_TOKEN_ADDRESS}` to verify the smart contract, and add the INFURA API key in .env file.
Testing.