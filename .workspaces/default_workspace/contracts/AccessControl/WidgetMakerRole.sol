// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'FarmerRole' to manage this role - add, remove, check
contract WidgetMakerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event WidgetMakerAdded(address indexed account);
  event WidgetMakerRemoved(address indexed account);

  // Define a struct 'widgetmakers' by inheriting from 'Roles' library, struct Role
  Roles.Role private widgetmakers;

  // In the constructor make the address that deploys this contract the 1st widgetmaker
  //constructor() public {
  //  _addWidgetMaker(msg.sender);
  //}

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyWidgetMaker() {
    require(isWidgetMaker(msg.sender), "WidgetMakerRole::onlyWidgetMaker - You need the widgetmaker role to do this action");
    _;
  }

  // Define a function 'isWidgetMaker' to check this role
  function isWidgetMaker(address account) public view returns (bool) {
    return widgetmakers.has(account);
  }

  // Define a function 'addWidgetMaker' that adds this role
  function addWidgetMaker(address account) public onlyWidgetMaker {
    _addWidgetMaker(account);
  }

  // Define a function 'renounceWidgetMaker' to renounce this role
  function renounceWidgetMaker() public {
    _removeWidgetMaker(msg.sender);
  }

  // Define an internal function '_addWidgetMaker' to add this role, called by 'addWidgetMaker'
  function _addWidgetMaker(address account) internal {
    widgetmakers.add(account);
    emit WidgetMakerAdded(account);
  }

  // Define an internal function '_removeWidgetMaker' to remove this role, called by 'renounceWidgetMaker'
  function _removeWidgetMaker(address account) internal {
    widgetmakers.remove(account);
    emit WidgetMakerRemoved(account);
  }
}