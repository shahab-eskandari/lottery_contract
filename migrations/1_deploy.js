const factory = artifacts.require('factory');

module.exports = async function (deployer) {
  await deployer.deploy(factory);
};