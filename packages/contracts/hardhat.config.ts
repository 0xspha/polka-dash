import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";

const config: HardhatUserConfig = {
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://localhost:8545",
      accounts: ["0x056385846800481f8767edda6f36a9a1b96eaa57b40d054214416f7d909eea97", "0xcbc6b58a521035bc7d0e01e1c9c0485b64511c248a8e4adc66ee0f702e3aba77"] //@dev these are test keys :XD
    },
    westend: {
      url: "https://westend-asset-hub-eth-rpc.polkadot.io",
      accounts: ["c2e7d02ad58e5d46ab32b623ea2c10c590aeaed5283c9c03e62d8fdda24f1705", "0xcbc6b58a521035bc7d0e01e1c9c0485b64511c248a8e4adc66ee0f702e3aba77"] //@dev these are test keys :XD
    }
  },
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }

};

export default config;
