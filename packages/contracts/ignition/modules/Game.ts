// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const GameModule = buildModule("GameModule", (m) => {
  const game = m.contract("Game", [], {});
  const token = m.contract("Token", ["GameToken", "GT", game], {});
  const nft = m.contract("NFT", ["NFTToken", "NT", game], {});
  const stream = m.contract("StreamCreator", [token, game], {});
  return { game,token,nft,stream };
});

export default GameModule;
