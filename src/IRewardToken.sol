// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface IRewardToken is IERC20 {
    function mint(address to, uint256 amount) external;
}
