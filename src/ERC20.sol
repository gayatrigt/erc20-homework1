// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import SafeTransfer library from OpenZeppelin
import "@openzeppelin/contracts/utils/Address.sol";

contract ERC20 {
    using Address for address;

    // Public variables for name, symbol, decimals, and total supply
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Mappings to track balances and allowances
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Events required by the ERC-20 standard
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // Constructor to set up the initial state
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name; // Token name
        symbol = _symbol; // Token symbol
        decimals = _decimals; // Number of decimal places for token representation
        totalSupply = _initialSupply * (10 ** _decimals); // Total supply, scaled by decimals
        balances[msg.sender] = totalSupply; // Assign the entire initial supply to the contract deployer
        emit Transfer(address(0), msg.sender, totalSupply); // Emit transfer from address(0) to signal minting
    }

    // Function to return the balance of an account
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Transfer tokens to another account
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount); // Internal transfer logic
        return true;
    }

    // Internal function to handle transfers
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "ERC20: transfer to zero address"); // Ensure recipient is valid
        require(balances[from] >= amount, "ERC20: insufficient balance"); // Ensure sender has enough tokens

        balances[from] -= amount; // Subtract amount from sender
        balances[to] += amount; // Add amount to recipient

        emit Transfer(from, to, amount); // Emit the Transfer event
    }

    // Approve an allowance for another account to spend on behalf of the caller
    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount; // Set allowance
        emit Approval(msg.sender, spender, amount); // Emit the Approval event
        return true;
    }

    // View the allowance given to a spender by an owner
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return allowances[owner][spender];
    }

    // Transfer tokens from one account to another using an allowance
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(
            allowances[from][msg.sender] >= amount,
            "ERC20: insufficient allowance"
        ); // Ensure enough allowance
        allowances[from][msg.sender] -= amount; // Deduct allowance
        _transfer(from, to, amount); // Perform transfer
        return true;
    }
}
