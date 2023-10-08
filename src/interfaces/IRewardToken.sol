// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRewardToken {
    function mint(address to, uint256 amount) external;
}
