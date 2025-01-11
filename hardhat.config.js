require("@nomicfoundation/hardhat-toolbox");
require("@dotenvx/dotenvx").config();

/** @type import('hardhat/config').HardhatUserConfig */


module.exports = {
  solidity: "0.8.28",
  networks : {
    sepolia : {
      chainId : 11155111,
      url:  process.env.ALCHEMY_SEPOLIA_API_KEY ? "https://eth-sepolia.g.alchemy.com/v2/" + process.env.ALCHEMY_SEPOLIA_API_KEY : "https://eth-sepolia.g.alchemy.com/v2/demo",
      accounts: process.env.SEPOLIA_SECURE_PRIVATE_KEY_1 ? [process.env.SEPOLIA_SECURE_PRIVATE_KEY_1] : [],
      saveDeployments: true
    }
  },
  etherscan: {
    apiKey: {
        sepolia: process.env.ETHERSCAN_API_KEY,
    }
  }
};
