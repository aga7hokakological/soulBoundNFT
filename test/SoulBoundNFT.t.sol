// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SoulBoundNFT.sol";

contract SoulBoundNFTTest is Test {
    SoulBoundNFT soulBound;

    error AlreadyMinted();
    error NotApproved();

    address owner = makeAddr("OWNER");
    address user1 = makeAddr("USER1");
    address user2 = makeAddr("USER2");
    address user3 = makeAddr("USER3");
    address user4 = makeAddr("USER4");

    function setUp() external {
        vm.prank(owner);
        soulBound = new SoulBoundNFT();
    }

    function test_Getters() external {
        assertEq(soulBound.owner(), owner);
    }

    function test_SafeMint() external {
        vm.startPrank(owner);
        soulBound.approveMinters(user1);
        soulBound.approveMinters(user2);
        vm.stopPrank();

        vm.prank(user1);
        soulBound.safeMint();
        vm.prank(user2);
        soulBound.safeMint();

        assertEq(soulBound.ownerOf(0), user1);
        assertEq(soulBound.ownerOf(1), user2);
    }

    function test_IfUserCanMintMoreThanOneNFT() external {
        vm.prank(owner);
        soulBound.approveMinters(user3);

        vm.prank(user3);
        soulBound.safeMint();
        vm.expectRevert(AlreadyMinted.selector);
        vm.prank(user3);
        soulBound.safeMint();
    }

    function test_UserCannotMintIfNotAuthorised() external {
        vm.expectRevert(NotApproved.selector);
        vm.prank(user4);
        soulBound.safeMint();
    }

    function test_IfNFTBurnsAfterTransfer() external {
        vm.prank(owner);
        soulBound.approveMinters(user1);

        vm.prank(user1);
        soulBound.safeMint();
        assertEq(soulBound.balanceOf(user1), 1);

        vm.prank(user1);
        soulBound.transferFrom(user1, user4, 0);

        assertEq(soulBound.balanceOf(user1), 0);
        assertEq(soulBound.balanceOf(user4), 0);
    }
}