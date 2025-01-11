const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ChainWarsModule", (m) => {

  const chainWars = m.contract("ChainWars");

  return { chainWars };
});