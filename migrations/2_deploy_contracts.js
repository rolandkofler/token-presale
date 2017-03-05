var ConvertLib = artifacts.require("./owned.sol");
var SikobaPresale = artifacts.require("./SikobaPresale.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, SikobaPresale);
  deployer.deploy(SikobaPresale, {from:web3.eth.accounts[0], value:15, gas:1000000});
};
