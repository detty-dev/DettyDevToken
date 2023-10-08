// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("Dettydev", "Dev") {
        _mint(to, amount);
    }
}