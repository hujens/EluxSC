// migrating the appropriate contracts
var SupplierRole = artifacts.require("./SupplierRole.sol");
var ContractorRole = artifacts.require("./ContractorRole.sol");
var CustomerRole = artifacts.require("./CustomerRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(SupplierRole);
  deployer.deploy(ContractorRole);
  deployer.deploy(CustomerRole);
  deployer.deploy(SupplyChain);
};
