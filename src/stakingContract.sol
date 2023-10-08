// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol"; 
import { IWETH }from "../src/interfaces/IWETH.sol";  
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IRewardToken} from "../src/interfaces/IRewardToken.sol";
import {ERC20} from "../src/ERC20.sol";
import {RewardToken} from "../src/RewardToken.sol";

                   

// Define your staking contract
contract StakingContract is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public ethToken;  
    IERC20 public wethToken; 
    IERC20 public rewardToken; 

    uint256 public rewardRate = 14; 
    uint256 public rewardRatio = 10; 

     struct StakerData {
        uint256 totalStaked;
        uint256 lastStakedTimestamp;
        uint256 reward;
        uint amount;
    }

    mapping(address => StakerData) public stakers;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastStakeTimestamp;

    uint256 public compoundingFee = 1; 
    uint256 public compoundingPeriod = 30 days; 

    constructor(
        address _ethToken,
        address _wethToken,
        address _rewardToken
    ) {
        ethToken = IERC20(_ethToken);
        wethToken = IERC20(_wethToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 amount) external {
         require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);

        StakerData storage staker = stakers[msg.sender];
        staker.reward = staker.reward+(calculateReward(msg.sender));
        staker.totalStaked = staker.totalStaked+(amount);
        staker.lastStakedTimestamp = block.timestamp;
        // Convert ETH to WETH
        ethToken.safeTransferFrom(msg.sender, address(this), amount);
        wethToken.deposit{value: amount}();
        stakedBalance[msg.sender] += amount;
        lastStakeTimestamp[msg.sender] = block.timestamp;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakedBalance[msg.sender] >= amount, "Insufficient balance");
        stakers[msg.sender].totalStaked = stakers[msg.sender].totalStaked-(amount);
        stakers[msg.sender].reward = stakers[msg.sender].reward-(calculateReward(msg.sender));
        stakedBalance[msg.sender] -= amount;
        lastStakeTimestamp[msg.sender] = block.timestamp;
        token.transfer(address(this), amount);
    }

    function deposit() external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 wethAmount = msg.value;
        wethToken.transferFrom(msg.sender, address(this), wethAmount);
        wethBalances[msg.sender] += wethAmount;
    }

    function withdraw(uint256 amount) external {
         require(amount > 0, "Amount must be greater than zero");
        require(wethBalances[msg.sender] >= amount, "Insufficient balance");
        wethToken.transfer(msg.sender, amount);
        wethBalances[msg.sender] -= amount;
    }
   
     function compoundRewards() external {
        uint256 rewards = calculateRewards(msg.sender);
        uint256 compoundingAmount = (rewards * compoundingRatio) / 100;
        require(compoundingAmount > 0, "No rewards to compound");
        uint256 fee = (compoundingAmount * compoundingFee) / 100;
        compoundingAmount -= fee;
        // Convert rewards to WETH
        rewardToken.safeTransferFrom(msg.sender, address(this), compoundingAmount);
        wethToken.deposit{value: compoundingAmount}();

        // Add compounded amount to the stake
        stakedBalance[msg.sender] += compoundingAmount;

        // Update the last compound timestamp
        lastStakeTimestamp[msg.sender] = block.timestamp;
    }

    function calculateRewards(address account) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastStakeTimestamp[account];
        uint256 rewardPerSecond = (stakedBalance[account] * rewardRate) / (365 days * rewardRatio);
        return timeElapsed * rewardPerSecond;
    }

    function setCompoundingFee(uint256 fee) external onlyOwner {
        compoundingFee = fee;
    }

    function setCompoundingPeriod(uint256 period) external onlyOwner {
        compoundingPeriod = period;
    }
}
