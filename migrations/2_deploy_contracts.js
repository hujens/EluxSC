// migrating the appropriate contracts
var SupplierRole = artifacts.require("./SupplierRole.sol");
var ContractorRole = artifacts.require("./ContractorRole.sol");
var OwnerRole = artifacts.require("./OwnerRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(SupplierRole);
  deployer.deploy(ContractorRole);
  deployer.deploy(OwnerRole);
  deployer.deploy(SupplyChain);
};
