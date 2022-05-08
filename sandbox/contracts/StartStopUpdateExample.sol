// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract EtherBank {
    address owner;
    uint256 public lastAmountReceived;

    constructor() payable minimumValue(msg.value) {
        owner = msg.sender;
        lastAmountReceived = msg.value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function deposit() public payable minimumValue(msg.value) {
        lastAmountReceived = msg.value;
    }

    function withdraw(uint256 _money) public mustBeOwner {
        address payable _to = payable(msg.sender);
        _to.transfer(_money);
    }

    function sendMoney(address payable _to, uint256 _money) public mustBeOwner {
        _to.transfer(_money);
    }

    modifier mustBeOwner() {
        require(msg.sender == owner, "You must be the Contract owner.");

        _;
    }

    modifier minimumValue(uint256 _money) {
        require(msg.value >= 1000, "Minimum depsoit required: 1000 wei");

        _;
    }
}
