pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'OwnerRole' to manage this role - add, remove, check
contract OwnerRole {

  // Define 2 events, one for Adding, and other for Removing

  // Define a struct 'owner' by inheriting from 'Roles' library, struct Role

  // In the constructor make the address that deploys this contract the 1st owner
  constructor() public {
    
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyOwner() {
    
    _;
  }

  // Define a function 'isOwner' to check this role
  function isOwner(address account) public view returns (bool) {
    
  }

  // Define a function 'addOwner' that adds this role
  function addOwner(address account) public onlyOwner {
    
  }

  // Define a function 'renounceOwner' to renounce this role
  function renounceOwner() public {
    
  }

  // Define an internal function '_addOwner' to add this role, called by 'addOwner'
  function _addOwner(address account) internal {
    
  }

  // Define an internal function '_removeOwner' to remove this role, called by 'removeOwner'
  function _removeOwner(address account) internal {
    
  }
}