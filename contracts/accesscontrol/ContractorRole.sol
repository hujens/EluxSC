pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ContractorRole' to manage this role - add, remove, check
contract ContractorRole {

  // Define 2 events, one for Adding, and other for Removing
  
  // Define a struct 'contractor' by inheriting from 'Roles' library, struct Role

  // In the constructor make the address that deploys this contract the 1st contractor
  constructor() public {
    
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyContractor() {
    
    _;
  }

  // Define a function 'isContractor' to check this role
  function isContractor(address account) public view returns (bool) {
    
  }

  // Define a function 'addContractor' that adds this role
  function addContractor(address account) public onlyContractor {
    
  }

  // Define a function 'renounceContractor' to renounce this role
  function renounceContractor()) public {
    
  }

  // Define an internal function '_addContractor' to add this role, called by 'addContractor'
  function _addContractor(address account) internal {
    
  }

  // Define an internal function '_removeContractor' to remove this role, called by 'removeContractor'
  function _removeContractor(address account) internal {
    
  }
}