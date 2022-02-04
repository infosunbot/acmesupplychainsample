// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";

import "../contracts/AcmeSupplyChain.sol";

contract AcmeSupplyChainTest {
   
    //bytes32[] proposalNames;
   
    AcmeSupplyChain acmeSupplyChainToTest;
    //address ownerID = accounts[0]
    address widgetMakerId = TestsAccounts.getAccount(1);
    //uint productPrice = web3.utils.toWei("1", "ether");

    address warehouseManagerID = TestsAccounts.getAccount(2);
    address customerID = TestsAccounts.getAccount(3);
    


    function beforeAll () public {

        acmeSupplyChainToTest = new AcmeSupplyChain();

        //acmeSupplyChainToTest.addWidgetMaker(widgetMakerId);
        acmeSupplyChainToTest.addWarehouseManager(warehouseManagerID);
        acmeSupplyChainToTest.addCustomer(customerID);

    }
    
    function WarehouseManagerAddStock() public payable {

        acmeSupplyChainToTest.addWarehouseManager(msg.sender);  // adding sender to warehouse manager list 
        acmeSupplyChainToTest.renounceCustomer();  // removing the sender from customer list if already there

        // we expect succes while updating the Inventory if sender in warehouse manager list 
        Assert.equal(acmeSupplyChainToTest.updateWidgetInventories(3), uint(3), "update stock amount looks correct");
    }
    
    function CustomerCanNotAddStockExpectFail () public {
        
        acmeSupplyChainToTest.addCustomer(msg.sender);  // adding sender to customer list
        acmeSupplyChainToTest.renounceWarehouseManager();  // removing the sender from warehouse manager list if already there
        
         acmeSupplyChainToTest.updateWidgetInventories(3);  // we expect error while updating the Inventory if sender in customer list
    }

    function CustomerPlaceOrder () public {

        acmeSupplyChainToTest.addWarehouseManager(msg.sender);  // adding sender to warehouse manager list 
        acmeSupplyChainToTest.renounceCustomer();  // removing the sender from customer list if already there
        acmeSupplyChainToTest.updateWidgetInventories(3);      
        
        Assert.equal(acmeSupplyChainToTest.orderWidget(1), uint(1), "order count looks correct");
    }



    function WarehouseManagerShipOrder () public {

        // we expect succes while updating the Inventory if sender in warehouse manager list 
        acmeSupplyChainToTest.updateWidgetInventories(3);

      
        Assert.equal(acmeSupplyChainToTest.shipOrder(1), uint(2), "stocklist was 3, after ship 1 we expect 2");
    }


}
