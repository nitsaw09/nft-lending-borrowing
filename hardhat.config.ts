import("@nomicfoundation/hardhat-toolbox");
import * as dotenv from "dotenv";

dotenv.config();

const { PRIVATE_KEY, INFURA_API_KEY, LINEASCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.19",
  networks: {
    linea_testnet: {
      url: `https://linea-goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    linea_mainnet: {
      url: `https://linea-mainnet.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      linea_testnet: LINEASCAN_API_KEY
    },
    customChains: [
      {
        network: "linea_testnet",
        chainId: 59140,
        urls: {
          apiURL: "https://api-testnet.lineascan.build/api",
          browserURL: "https://goerli.lineascan.build/address"
        }
      }
    ]
  }
};
