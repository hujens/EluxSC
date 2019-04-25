pragma solidity >=0.4.24;

// Import the library 'Roles'
import "./Roles.sol";
// Import 'Roles' directly from OpenZeppelin:
// openzeppelin-solidity/contracts/access/Roles.sol

// Define a contract 'ContractorRole' to manage this role - add, remove, check
contract ContractorRole {
  using Roles for Roles.Role;
  
  // Define 2 events, one for Adding, and other for Removing
  event ContractorAdded(address indexed account);
  event ContractorRemoved(address indexed account);

  // Define a struct 'contractor' by inheriting from 'Roles' library, struct Role
  Roles.Role private contractors;

  // In the constructor make the address that deploys this contract the 1st contractor
  constructor() public {
    _addContractor(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyContractor() {
    require(isContractor(msg.sender));
    _;
  }

  // Define a function 'isContractor' to check this role
  function isContractor(address account) public view returns (bool) {
    return contractors.has(account);
  }

  // Define a function 'addContractor' that adds this role
  function addContractor(address account) public onlyContractor {
    _addContractor(account);
  }

  // Define a function 'renounceContractor' to renounce this role
  function renounceContractor() public {
    _removeContractor(msg.sender);
  }

  // Define an internal function '_addContractor' to add this role, called by 'addContractor'
  function _addContractor(address account) internal {
    contractors.add(account);
    emit ContractorAdded(account);
  }

  // Define an internal function '_removeContractor' to remove this role, called by 'removeContractor'
  function _removeContractor(address account) internal {
    contractors.remove(account);
    emit ContractorRemoved(account);
  }
}