// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'WarehouseManagerRole' to manage this role - add, remove, check
contract WarehouseManagerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event WarehouseManagerAdded(address indexed account);
  event WarehouseManagerRemoved(address indexed account);

  // Define a struct 'warehouseManagers' by inheriting from 'Roles' library, struct Role
  Roles.Role private warehouseManagers;

  constructor() {
    _addWarehouseManager(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyWarehouseManager() {
    require(isWarehouseManager(msg.sender), "WarehouseManagerRole::onlyWarehouseManager - only a WarehouseManager can perform this action");
    _;
  }

  // Define a function 'isWarehouseManager' to check this role
  function isWarehouseManager(address account) public view returns (bool) {
    return warehouseManagers.has(account);
  }

  // Define a function 'addWarehouseManager' that adds this role
  function addWarehouseManager(address account) public onlyWarehouseManager {
    _addWarehouseManager(account);
  }

  // Define a function 'renounceWarehouseManager' to renounce this role
  function renounceWarehouseManager() public {
    _removeWarehouseManager(msg.sender);
  }

  // Define an internal function '_addWarehouseManager' to add this role, called by 'addWarehouseManager'
  function _addWarehouseManager(address account) internal {
    warehouseManagers.add(account);
    emit WarehouseManagerAdded(account);
  }

  // Define an internal function '_removeWarehouseManager' to remove this role, called by 'removeWarehouseManager'
  function _removeWarehouseManager(address account) internal {
    warehouseManagers.remove(account);
    emit WarehouseManagerRemoved(account);
  }
}