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
    
    function SuccessWarehouseManagerAddStock() public payable {

                // account index varies 0-9, value is in wei
       // Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
       // Assert.equal(msg.value, 100, "Invalid value");

        Assert.equal(acmeSupplyChainToTest.updateWidgetInventories(3), uint(3), "update stock amount looks correct");
        //Assert.equal(acmeSupplyChainToTest.updateWidgetInventories(3), uint(1), "update stock amount looks not correct");
    }
    
    function CustomerCanNotAddStock () public {

        Assert.ok(msg.sender == customerID, 'only a WarehouseManager can perform this action');

         acmeSupplyChainToTest.updateWidgetInventories( 3);
    }

    function CustomerPlaceOrder () public {

      
        Assert.equal(acmeSupplyChainToTest.orderWidget(1), uint(1), "order count looks correct");
    }


}
