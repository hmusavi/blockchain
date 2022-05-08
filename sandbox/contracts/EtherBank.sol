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
        uint256 numTransaction;
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

    fallback() external payable {
        _deposit(msg.sender, msg.value);
    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
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

    function getBalance(address _address)
        public
        view
        contractIsActive
        mustBeOwner
        returns (uint256)
    {
        return balances[_address].totalBalance;
    }

    function deposit() public payable {
        _deposit(msg.sender, msg.value);
    }

    function _deposit(address _address, uint256 _money)
        private
        contractIsActive
    {
        Payment memory payment = Payment({
            amount: int256(_money),
            timestamp: block.timestamp
        });

        balances[_address].totalBalance += uint256(payment.amount);
        balances[_address].payments[
            balances[_address].numTransaction
        ] = payment;
        balances[_address].numTransaction++;
    }

    function withdraw(uint256 _money) public {
        payable(msg.sender).transfer(_withdraw(_money));
    }

    function send(address payable _to, uint256 _money) public {
        _to.transfer(_withdraw(_money));
    }

    function transfer(address payable _to, uint256 _money) public {
        _deposit(_to, _withdraw(_money));
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
        balance.payments[balance.numTransaction] = payment;
        balance.numTransaction++;
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
