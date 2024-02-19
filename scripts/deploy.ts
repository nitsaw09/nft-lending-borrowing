import { ethers } from "hardhat";
import deployConfig from "../config/deploy.config";

async function main() {
  const Contract = await ethers.getContractFactory("NFTLending");
  const contract = await Contract.deploy(
    deployConfig.NFT_TOKEN_ADDRESS
  );

  await contract.deployed();

  console.log("Contract deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});