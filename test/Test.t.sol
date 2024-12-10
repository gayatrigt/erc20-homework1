// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner;
    address public alice;
    address public bob;

    // Initial token configuration
    string public constant NAME = "My Token";
    string public constant SYMBOL = "MTK";
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000; // 1 million tokens

    function setUp() public {
        // Set up accounts
        owner = address(this);
        alice = address(0x1);
        bob = address(0x2);

        // Deploy token
        token = new MyToken(NAME, SYMBOL, DECIMALS, INITIAL_SUPPLY);

        // Label addresses for better trace output
        vm.label(owner, "Owner");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
    }

    // Test initial setup
    function test_InitialSetup() public {
        assertEq(token.name(), NAME);
        assertEq(token.symbol(), SYMBOL);
        assertEq(token.decimals(), DECIMALS);
        assertEq(token.totalSupply(), INITIAL_SUPPLY * (10 ** DECIMALS));
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * (10 ** DECIMALS));
    }

    // Test transfer
    function test_Transfer() public {
        uint256 amount = 1000 * (10 ** DECIMALS);

        // Check initial balances
        assertEq(token.balanceOf(alice), 0);

        // Transfer tokens
        bool success = token.transfer(alice, amount);

        // Assert transfer was successful
        assertTrue(success);
        assertEq(token.balanceOf(alice), amount);
        assertEq(
            token.balanceOf(owner),
            (INITIAL_SUPPLY * (10 ** DECIMALS)) - amount
        );
    }

    // Test transfer fails with insufficient balance
    function test_TransferInsufficientBalance() public {
        uint256 amount = (INITIAL_SUPPLY + 1) * (10 ** DECIMALS);

        // Expect revert
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(alice, amount);
    }

    // Test approve and transferFrom
    function test_ApproveAndTransferFrom() public {
        uint256 amount = 1000 * (10 ** DECIMALS);

        // Approve Bob to spend Alice's tokens
        token.transfer(alice, amount); // First give Alice some tokens

        vm.startPrank(alice);
        token.approve(bob, amount);
        vm.stopPrank();

        // Check allowance
        assertEq(token.allowance(alice, bob), amount);

        // Bob transfers tokens from Alice to himself
        vm.startPrank(bob);
        bool success = token.transferFrom(alice, bob, amount);
        vm.stopPrank();

        // Assert transfer was successful
        assertTrue(success);
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.allowance(alice, bob), 0);
    }

    // Test transferFrom fails without approval
    function test_TransferFromWithoutApproval() public {
        uint256 amount = 1000 * (10 ** DECIMALS);

        // Give Alice some tokens
        token.transfer(alice, amount);

        // Bob tries to transfer without approval
        vm.startPrank(bob);
        vm.expectRevert("ERC20: insufficient allowance");
        token.transferFrom(alice, bob, amount);
        vm.stopPrank();
    }

    // Test approve
    function test_Approve() public {
        uint256 amount = 1000 * (10 ** DECIMALS);

        // Approve spending
        bool success = token.approve(alice, amount);

        // Assert approval was successful
        assertTrue(success);
        assertEq(token.allowance(owner, alice), amount);
    }

    // Test zero address transfers
    function test_TransferToZeroAddress() public {
        uint256 amount = 1000 * (10 ** DECIMALS);

        // Expect revert
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(address(0), amount);
    }

    // Test maximum allowance
    function test_MaximumAllowance() public {
        // Approve maximum amount
        token.approve(alice, type(uint256).max);

        // Transfer some tokens multiple times
        uint256 amount = 1000 * (10 ** DECIMALS);

        vm.startPrank(alice);
        token.transferFrom(owner, bob, amount);
        token.transferFrom(owner, bob, amount);
        token.transferFrom(owner, bob, amount);
        vm.stopPrank();

        // Allowance should still be maximum
        assertEq(token.allowance(owner, alice), type(uint256).max);
    }

    // Fuzz testing for transfer
    function testFuzz_Transfer(uint256 amount) public {
        // Bound the amount to total supply to avoid unrealistic values
        amount = bound(amount, 0, token.totalSupply());

        bool success = token.transfer(alice, amount);
        assertTrue(success);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), token.totalSupply() - amount);
    }
}
