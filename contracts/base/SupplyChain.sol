pragma solidity >=0.4.24;

//Import the role contracts to use its modifiers
import "../accesscontrol/SupplierRole.sol";
import "../accesscontrol/ContractorRole.sol";
import "../accesscontrol/CustomerRole.sol";

//Import ownable contract
//import "../core/Ownable.sol";

// Define a contract 'Supplychain' inheriting the contracts imported above
contract SupplyChain is SupplierRole, ContractorRole, CustomerRole {

  // Define 'owner'
  address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Produced,  // 0
    ForSale, // 1
    Sold,  // 2
    Shipped,     // 3
    Received,    // 4
    Installed,       // 5
    CheckPassed,    // 6
    CheckFailed,    // 7
    Paid,   // 8
    HandedOver // 9
    }

  State constant defaultState = State.Produced;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Supplier, goes on the package, can be verified by the Customer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address supplierID; // Metamask-Ethereum address of the Supplier
    string  supplierName; // Supplier Name
    string  supplierInformation;  // Supplier Information
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address contractorID;  // Metamask-Ethereum address of the Contractor
    string  contractorName; // Contractor Name
    string  contractorInformation; // Contractor Information
    uint    installationPrice; // Price to install the product
    address customerID; // Metamask-Ethereum address of the Consumer
    string  customerName; // Customer Name
  }

  // Define 10 events with the same 10 state values and accept 'upc' as input argument
  event Produced(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event Installed(uint upc);
  event CheckPassed(uint upc);
  event CheckFailed(uint upc);
  event Failed(uint upc);
  event Paid(uint upc);
  event HandedOver(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the product price and refunds the remaining balance to the contractor
  modifier checkValue(uint _upc) {
    _; //first needs to transfer money
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].contractorID.transfer(amountToReturn);
  }

  // TODO: Define a modifier that checks if the paid amount is sufficient to cover the total price
  modifier paidEnoughTotal(uint _price) { 
    require(msg.value >= _price); 
    _;
  }

  // TODO: Define a modifier that checks the total price and refunds the remaining balance to the customer
  modifier checkValueTotal(uint _upc) {
    _; //first needs to transfer money
    uint _price = items[_upc].productPrice + items[_upc].installationPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].customerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Produced
  modifier produced(uint _upc) {
    require(items[_upc].itemState == State.Produced);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received or CheckedFailed
  modifier readyForInstallation(uint _upc) {
    if (items[_upc].itemState == State.Received) {
      require(items[_upc].itemState == State.Received);
    } else {
      require(items[_upc].itemState == State.CheckFailed);
    }
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Installed
  modifier installed(uint _upc) {
    require(items[_upc].itemState == State.Installed);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is CheckedPassed
  modifier checked(uint _upc) {
    require(items[_upc].itemState == State.CheckPassed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Paid
  modifier paid(uint _upc) {
    require(items[_upc].itemState == State.Paid);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is HandedOver
  modifier handedOver(uint _upc) {
    require(items[_upc].itemState == State.HandedOver);
    _;
  }
  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }

  // Define a function 'produceItem' that allows a supplier to mark an item 'Produced'
  function produceItem(uint _upc, address _supplierID, string memory _supplierName, string memory _supplierInformation, string memory  _productNotes) public
  // Call modifier to verify caller of this function
  onlySupplier
  {
    // Add the new item as part of Produced
    items[sku] = Item({
      sku: sku,
      upc: _upc,
      ownerID: msg.sender,
      supplierID: _supplierID,
      supplierName: _supplierName,
      supplierInformation: _supplierInformation,
      productNotes: _productNotes,
      productPrice: 0,
      itemState: State.Produced,
      contractorID: address(0),
      contractorName: "",
      contractorInformation: "",
      installationPrice: 0,
      customerID: address(0)
      });
    // Emit the appropriate event
    emit Produced(sku);
    // Increment sku
    sku = sku + 1;
  }

  // Define a function 'sellItem' that allows a supplier to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public
  // Call modifier to verify caller of this function
  onlySupplier
  // Call modifier to check if upc has passed previous supply chain stage
  produced(_upc)
  {
    // Update fields: itemState, productPrice
    items[_upc].itemState = State.ForSale;
    items[_upc].productPrice = _price;
    // Emit event
    emit ForSale(_upc);
  }

  // Define a function 'buyItem' that allows the contractor to buy an item and mark it 'Sold'
  function buyItem(uint _upc, address _contractorID, string memory _contractorName, string memory _contractorInformation, address _customerID, string memory _customerName) public payable 
  // Call modifier to verify caller of this function
  onlyContractor
  // Call modifier to check if upc has passed previous supply chain stage
  forSale(_upc)
  // Call modifer to check if buyer has paid enough
  paidEnough(msg.value)
  // Call modifer to send any excess ether back to buyer
  checkValue(_upc)
  {
    // Update fields - itemState, contractorID, contractorName, contractorInformation, customerID, customerName
    items[_upc].itemState = State.Sold;
    items[_upc].ownerID = msg.sender;
    items[_upc].contractorID = _contractorID;
    items[_upc].contractorName = _contractorName;
    items[_upc].contractorInformation = _contractorInformation;
    items[_upc].customerID = _customerID;
    items[_upc].customerName = _customerName;
    // Transfer money to supplier
    uint productPrice = items[_upc].productPrice;
    items[_upc].supplierID.transfer(productPrice);
    // Emit event
    emit Sold(_upc);
  }

  // Define a function 'shipItem' that allows the supplier to mark an item 'Shipped'
  function shipItem(uint _upc) public
  // Call modifier to verify caller of this function
  onlySupplier
  // Call modifier to check if upc has passed previous supply chain stage
  sold(_upc)
  {
    // Update state
    items[_upc].itemState = State.Shipped;
    // Emit event
    emit Shipped(_upc);
  }

  // Define a function 'receiveItem' that allows the contractor to mark an item 'Received'
  function receiveItem(uint _upc) public 
  // Call modifier to verify caller of this function
  onlyContractor
  // Call modifier to check if upc has passed previous supply chain stage
  shipped(_upc)
  {
    // Update state
    items[_upc].itemState = State.Received;
    // Emit event
    emit Received(_upc);
  }

  // Define a function 'installItem' that allows the contractor to mark an item 'Installed'
  function intallItem(uint _upc, uint _installationPrice) public 
  // Call modifier to verify caller of this function
  onlyContractor
  // Call modifier to check if upc has passed previous supply chain stage (received or checkedFailed)
  readyForInstallation(_upc)
  {
    // Update fields: itemState, installationPrice
    items[_upc].itemState = State.Installed;
    items[_upc].installationPrice = _installationPrice;
    // Emit the appropriate event
    emit Installed(_upc);
  }

  // Define a function 'checkItem' that allows the customer to mark an item 'Checked'
  // Input _checkPassed indicates whether check was successfull
  function checkItem(uint _upc, address _customerID, bool _checkPassed) public 
  // Call modifier to verify caller of this function
  onlyCustomer
  // Call modifier to check if upc has passed previous supply chain stage
  installed(_upc)
  {
    // Update the appropriate fields
    if (_checkPassed == true) {
      items[_upc].itemState = State.CheckedPassed;
      // Emit event
      emit CheckPassed(_upc);
    } else {
      items[_upc].itemState = State.CheckedFailed;
      // Emit event
      emit CheckFailed(_upc);
    }
  }

  // Define a function 'payItem' that allows the customer to mark an item 'Paid'
  function payItem(uint _upc) public payable
  // Call modifier to verify caller of this function
  onlyCustomer
  // Call modifier to check if upc has passed previous supply chain stage
  checked(_upc)
  // Call modifer to check if customer has paid enough
  paidEnoughTotal(msg.value)
  // Call modifer to send any excess ether back to buyer
  checkValueTotal(_upc)
  {
    // Transfer money to contractor
    uint totalPrice = items[_upc].productPrice + items[_upc].installationPrice;
    items[_upc].supplierID.transfer(totalPrice);
    // Emit event
    emit Paid(_upc);
  }

  // Define a function 'handOverItem' that allows the customer to mark an item 'HandedOver'
  function handOverItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Access Control List enforced by calling Smart Contract / DApp
    {
    // Update the appropriate fields
    
    // Emit the appropriate event
    
  }

  // Define a function 'fetchItemBufferOne' that fetches the first data entries (max. 9)
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSku,
  uint    itemUpc,
  address ownerID,
  address supplierID,
  string memory supplierName,
  string memory supplierInformation,
  string memory productNotes,
  uint    productPrice
  ) 
  {
  // Assign values to the parameters
  
  return 
  (
  itemSku,
  itemUpc,
  ownerID,
  supplierID,
  supplierName,
  supplierInformation,
  productNotes,
  productPrice
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the rest of the data entries (max. 9)
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  address contractorID,
  string memory contractorName,
  string memory contractorInformation,
  uint  installationPrice,
  address customerID,
  string memory customerName
  ) 
  {
    // Assign values to the parameters
  
  return 
  (
  contractorID,
  contractorName,
  contractorInformation,
  installationPrice,
  customerID,
  customerName
  );
  }
}
