// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./AccessControl/CustomerRole.sol";
import "./AccessControl/WidgetMakerRole.sol";
import "./AccessControl/WarehouseManagerRole.sol";
import "./Helper/Ownable.sol";
import "./Helper/SafeMath.sol";

// Define a contract 'AcmeSupplyChain'
contract AcmeSupplyChain is Ownable, CustomerRole, WidgetMakerRole, WarehouseManagerRole {
  using SafeMath for uint256;

  uint  sku;  //stock Keeping Unit
  uint orderCount;
  uint _price;
    // Define 'owner'
  address payable owner;

  // Define a public mapping 'widgets' that maps the UPC to an Widget.
  mapping (uint => Widget) widgets;
  mapping (uint => Order) orders;

  // Define a public mapping 'widgetsHistory' that maps the SKU to an array of TxHash, 
  // that track its journey through the widget supply chain -- to be sent from DApp.
  mapping (uint => string[]) widgetsHistory;
  
  enum WidgetState 
  { 
    Made,   // 0
    InWarehouse, // 1
    Ordered, // 2
    Approved, // 3
    Shipped   // 4
  }

    enum OrderState 
  { 
    Pending, 
    Approved,
    Rejected
  }

  struct Widget {
    uint    sku;  // Stock Keeping Unit (SKU)
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 4 stages
    //address originWidgetmakerID; // Metamask-Ethereum address of the widget producer
    uint    productPrice; // Product Price
    WidgetState   widgetState;  // Product State as represented in the enum above
    address warehouseManagerID;  // Metamask-Ethereum address of the Widget Warehouse manager
    address payable customerID; // Metamask-Ethereum address of the Consumer
  }

  
    struct Order {
        uint OrderId;
        OrderState state; // if true, that purchase already approved
        address payable customerID; // Metamask-Ethereum address of the Consumer
        uint widgetCount;   // how many widgets they are buying
    }

  // Define 3 events with the same 3 state values and accept 'sku' as input argument
  event Made(uint sku);
  event InWarehouse(uint sku);
  event Shipped(uint sku);

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address payable _address) {
    require(msg.sender == _address, "AcmeSupplyChain::verifyCaller - The caller is not the one supposed"); 
    _;
  }

  constructor() public payable {
    owner = payable(msg.sender);
    sku = 1;
    orderCount = 1;
    _price = 1;
  }

  // Define a function 'makeWidget' that allows a creater to mark an item 'Made'
  function makeWidget() public onlyWidgetMaker {
    // make the new item as part of Factory
    // Widget({
     //   sku: sku,
      //  ownerID: msg.sender,
      //  originWidgetmakerID: msg.sender,
      //  productPrice: 0,
      //  widgetState: WidgetState.Made,
      //  warehouseManagerID: address(0),
       // customerID: address(0)
    //});
    
    // Increment sku
    sku = sku.add(1);

    // Emit the Made event
    emit Made(sku);
    
  }

  function updateWidgetInventories(uint amount) public  onlyWarehouseManager returns (uint sku) {
      //Feature: Customer can NOT alter stock in inventory, onlyWarehouseManager check on function signature


    for (uint i = 0; i < amount; i++) {
        //Feature: Warehouse manager can add stock to the inventory
        // Increment sku/ 
        sku = sku.add(1);

        widgets[sku] = Widget({
            sku: sku,
            ownerID: msg.sender,
            productPrice: _price,
            widgetState: WidgetState.InWarehouse,
            warehouseManagerID: msg.sender,
            customerID: payable(address(0))
            });

        // Emit the InWarehouse event
        emit InWarehouse(sku);

        
            
        }
    return sku;
  }

  function orderWidget(uint amount) public  payable returns (uint orderCount)  {
    //User Story : 2,3 bullet 1 Given that the user is a customer, there is "payable" key on function signature above

    //User Story: 3 bullet 2 Given that the warehouse does NOT have enough stock Then the order is rejected
    require(amount < sku, "Not enough stock! order is rejected!");

    //assumed all widgets prices same, those are fungible
    uint calculatedPrice = amount.mul(_price);

    require( calculatedPrice < msg.value , "has not enough funds! order is rejected!");

      owner.transfer(calculatedPrice);  //transfer funds from customer to owner

      // Funds sent but owner haven't updated, ordered widgets owner will be updated  on shipOrder function

        orders[orderCount] = Order({
            OrderId: orderCount,
            //User Story: 2 bullet 3 Then the order is accepted
            state: OrderState.Pending,
            customerID: payable(msg.sender),
            widgetCount: amount
            });
    
    // the amount of Order Count is updated
    orderCount = orderCount.add(1);
    return orderCount;
  }

  function shipOrder(uint orderId) public onlyWarehouseManager  returns (address customer)  {
    //User Story : 4 bullet 1, Given that the user is a warehouse manager
    //onlyWarehouseManager can call this function

    //User Story : 4 bullet 2, Given that a customer order has been accepted
    //customer order has been accepted
    orders[orderId].state = OrderState.Approved;

    address customer = orders[orderId].customerID;

    for (uint i = 0; i < orders[orderId].widgetCount; i++) {

            widgets[sku].ownerID= customer;
            //User Story : 4 bullet 3, Then that order can be flagged as shipped below
            widgets[sku].widgetState= WidgetState.Shipped;
            widgets[sku].warehouseManagerID= msg.sender;
            widgets[sku].customerID= orders[orderId].customerID;


      //User Story : 4 bullet 4, And the amount of stock in the warehouse is updated
        // the amount of stock in the warehouse is updated
        sku = sku.sub(1);

        // Emit the Ship event
        emit Shipped(sku);
            return customer;
        }
  }

}