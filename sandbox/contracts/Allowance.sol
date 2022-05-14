// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.6.0/contracts/access/Ownable.sol";

import "./Activable.sol";

contract Allowance is Ownable, Activable {
    struct Payment {
        int256 amount;
        uint256 timestamp;
    }

    struct Balance {
        uint256 numTransaction;
        mapping(uint256 => Payment) payments;
    }

    Balance _balance;

    receive() external payable {
        _deposit(msg.value);
    }

    function getBalance() public view contractIsActive returns (uint256) {
        return address(this).balance;
    }

    function deposit() public payable {
        _deposit(msg.value);
    }

    function _deposit(uint256 _money) private contractIsActive {
        Payment memory payment = Payment({
            amount: int256(_money),
            timestamp: block.timestamp
        });

        _balance.payments[_balance.numTransaction] = payment;
        _balance.numTransaction++;
    }

    function withdraw(uint256 _money) public {
        payable(msg.sender).transfer(_withdraw(_money));
    }

    function send(address payable _to, uint256 _money) public {
        _to.transfer(_withdraw(_money));
    }

    function _withdraw(uint256 _money)
        private
        contractIsActive
        minimumAmount(_money)
        sufficientFunds(_money)
        returns (uint256)
    {
        Payment memory payment = Payment({
            amount: -int256(_money),
            timestamp: block.timestamp
        });

        _balance.payments[_balance.numTransaction] = payment;
        _balance.numTransaction++;
        return _money;
    }

    modifier minimumAmount(uint256 _money) {
        require(_money > 0, "Transaction requires minimum amount 1 wei");

        _;
    }

    modifier sufficientFunds(uint256 _money) {
        require(address(this).balance >= _money, "Insuffuicient funds");
        _;
    }
}
