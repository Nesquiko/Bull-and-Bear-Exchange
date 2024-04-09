// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {BBToken} from "../src/BBToken.sol";
import {DeployContracts} from "../script/DeployContracts.s.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BBTokenTest is Test {
    DeployContracts deployer;
    BBToken token;
    address owner;
    address user;

    function setUp() public {
        deployer = new DeployContracts();
        (token,, owner) = deployer.run();
        user = makeAddr("user");
    }

    function testSupplyIsSet() public {
        uint256 suuply = 20;
        vm.prank(user);
        BBToken bbToken = new BBToken(suuply);
        assertEq(suuply * 10 ** bbToken.decimals(), bbToken.totalSupply());
    }
}
