// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./TestSetup.sol";

contract TheWeb3TokenTest is TestSetup {
    TheWeb3TokenV1 public proxyToken;

    function setUp() public override {
        super.setUp();
        proxyToken = TheWeb3TokenV1(address(proxy));
    }

    function test_Initialize() public view {
        assertEq(proxyToken.owner(), owner);
        assertEq(proxyToken.totalSupply(), INITIAL_SUPPLY);
        assertEq(proxyToken.remainingSupply(), INITIAL_SUPPLY);
    }

    function test_Transfer() public {
        vm.prank(owner);
        proxyToken.transfer(user1, 1000);
        assertEq(proxyToken.balanceOf(user1), 1000);
    }

    function test_TransferOwnership() public {
        vm.prank(owner);
        proxyToken.transferOwnership(user1);
        assertEq(proxyToken.owner(), user1);
    }

    function testFail_TransferOwnershipByNonOwner() public {
        vm.prank(user1);
        proxyToken.transferOwnership(user2);
    }

    function testFail_TransferOwnershipToZeroAddress() public {
        vm.prank(owner);
        proxyToken.transferOwnership(address(0));
    }

    function test_GetRemainingSupply() public view {
        assertEq(proxyToken.getRemainingSupply(), INITIAL_SUPPLY);
    }
} 
