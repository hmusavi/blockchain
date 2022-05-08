// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract EtherBank {
    address public owner;
    bool active;

    struct Payment {
        int256 amount;
        uint256 timestamp;
    }

    struct Balance {
        uint256 totalBalance;
        uint256 numPayments;
        mapping(uint256 => Payment) payments;
    }

    mapping(address => Balance) balances;

    constructor() {
        active = true;
        owner = msg.sender;
    }

    function setActive(bool _active) public mustBeOwner {
        active = _active;
    }

    function getBankBalance()
        public
        view
        contractIsActive
        mustBeOwner
        returns (uint256)
    {
        return address(this).balance;
    }

    function getBalance() public view contractIsActive returns (uint256) {
        return balances[msg.sender].totalBalance;
    }

    function deposit() public payable contractIsActive {
        Payment memory payment = Payment({
            amount: int256(msg.value),
            timestamp: block.timestamp
        });

        balances[msg.sender].totalBalance += uint256(payment.amount);
        balances[msg.sender].payments[
            balances[msg.sender].numPayments
        ] = payment;
        balances[msg.sender].numPayments++;
    }

    function withdraw(uint256 _money) public {
        payable(msg.sender).transfer(_withdraw(_money));
    }

    function sendMoney(address payable _to, uint256 _money) public {
        _to.transfer(_withdraw(_money));
    }

    function _withdraw(uint256 _money)
        private
        contractIsActive
        minimumAmount(_money)
        sufficientFunds(_money)
        returns (uint256)
    {
        Balance storage balance = balances[msg.sender];
        Payment memory payment = Payment({
            amount: -int256(_money),
            timestamp: block.timestamp
        });

        balance.totalBalance -= _money;
        balance.payments[balance.numPayments] = payment;
        balance.numPayments++;
        return _money;
    }

    modifier contractIsActive() {
        require(active, "Contract is currently disabled. Try later.");

        _;
    }

    modifier minimumAmount(uint256 _money) {
        require(_money > 0, "Transaction requires minimum amount 1 wei");

        _;
    }

    modifier mustBeOwner() {
        require(msg.sender == owner, "Not authorized");

        _;
    }

    modifier sufficientFunds(uint256 _money) {
        require(
            balances[msg.sender].totalBalance >= _money,
            "Insuffuicient funds"
        );

        require(
            address(this).balance >= _money,
            "Insuffuicient funds in the bank. Try again later."
        );

        _;
    }
}
