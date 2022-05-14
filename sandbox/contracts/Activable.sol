// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

abstract contract Activable {
    bool active;

    constructor() {
        active = true;
    }

    function setActive(bool _active) public {
        active = _active;
    }

    modifier contractIsActive() {
        require(active, "Contract is currently disabled. Try later.");

        _;
    }
}
