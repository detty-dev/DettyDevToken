// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/stakingContract.sol";
import "forge-std/Test.sol";

contract StakingContractTest is Test {
    StakingContract stakingContract;

    function setUp() public {
        stakingContract = new StakingContract();
    }

    function testStake() public {
        uint256 amount = 100;

        // Stake some ETH
        stakingContract.stake(amount);

        // Check that the staked balance is correct
        assertEq(stakingContract.stakedBalance(address(this)), amount);
    }

    function testUnstake() public {
        uint256 amount = 100;

        // Stake some ETH
        stakingContract.stake(amount);

        // Unstake some ETH
        stakingContract.unstake(amount);

        // Check that the staked balance is correct
        assertEq(stakingContract.stakedBalance(address(this)), 0);
    }

    function testCalculateRewards() public {
        uint256 amount = 100;

        // Stake some ETH
        stakingContract.stake(amount);

        // Calculate the rewards
        uint256 rewards = stakingContract.calculateRewards(address(this));

        // Check that the rewards are correct
        assert(rewards > 0);
    }
}