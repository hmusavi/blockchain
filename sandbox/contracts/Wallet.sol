// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.6.0/contracts/access/Ownable.sol";

import "./Allowance.sol";

contract Wallet is Ownable, Activable {
    mapping(address => Allowance) allowances;

    constructor() {
        active = true;
    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    function getBankBalance()
        public
        view
        contractIsActive
        onlyOwner
        returns (uint256)
    {
        return address(this).balance;
    }

    function getBalance() public view contractIsActive returns (uint256) {
        return address(allowances[msg.sender]).balance;
    }

    function getBalance(address _address)
        public
        view
        contractIsActive
        onlyOwner
        returns (uint256)
    {
        return allowances[_address].getBalance();
    }

    function deposit() public payable {
        _deposit(msg.sender, msg.value);
    }

    function deposit(address _address) public payable {
        _deposit(_address, msg.value);
    }

    function _deposit(address _address, uint256 _money)
        private
        contractIsActive
    {
        allowances[_address].deposit();
    }

    function withdraw(uint256 _money) public {
        allowances[msg.sender].withdraw(_money);
    }
}
