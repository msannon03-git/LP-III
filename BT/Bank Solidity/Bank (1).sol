// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * Title: Bank Account Smart Contract
 * Aim: To perform basic banking operations - Deposit, Withdraw, and Check Balance
 * Description:
 * This contract allows users to deposit and withdraw Ether securely.
 * Each user has their own balance, and only they can withdraw their funds.
 * The contract also accepts Ether during deployment.
 */

contract Bank {

    // Mapping to store balances of each user
    mapping(address => uint256) public balanceOf;

    // Variable to store total balance of the bank
    uint256 public totalBankBalance;

    // Event logs
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    // Payable constructor to accept Ether during deployment
    constructor() payable {
        if (msg.value > 0) {
            balanceOf[msg.sender] = msg.value;
            totalBankBalance += msg.value;
            emit Deposit(msg.sender, msg.value);
        }
    }

    // Deposit money into the bank
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balanceOf[msg.sender] += msg.value;
        totalBankBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw money from the bank
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balanceOf[msg.sender], "Insufficient balance");

        // Update balances before transfer
        balanceOf[msg.sender] -= amount;
        totalBankBalance -= amount;

        // Transfer amount to sender
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    // View the balance of the caller
    function getBalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }

    // View the total balance stored in the bank
    function getTotalBankBalance() public view returns (uint256) {
        return totalBankBalance;
    }
}
