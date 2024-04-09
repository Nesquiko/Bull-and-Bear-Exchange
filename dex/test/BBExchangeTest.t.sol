// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {BBToken} from "../src/BBToken.sol";
import {BBExchange} from "../src/BBExchange.sol";
import {DeployContracts} from "../script/DeployContracts.s.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract BBExchangeTest is Test {
    DeployContracts deployer;
    BBToken token;
    BBExchange exchange;
    address owner;
    address user;

    function setUp() public {
        deployer = new DeployContracts();
        (token, exchange, owner) = deployer.run();
        user = makeAddr("user");
    }

    /// @notice An example on how to use different Foundry test functions
    /// @dev more can be found at https://book.getfoundry.sh/
    function testExample() public {
        // gives 100 ether to user
        vm.deal(user, 100 ether);
        // asserts that specified two values are equal,
        // more asserts here https://book.getfoundry.sh/reference/ds-test?highlight=assert#asserting
        assertEq(100 ether, user.balance);

        // set user as sender of next call (excluding calls to test functions),
        // vm.startPrank and vm.stopPrank can be used to set user for multiple
        // calls in between calls to these two functions
        vm.prank(user);
        // if the next call (excluding calls to test functions) doesn't revert
        // with the specified error, fail test
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.transfer(address(0), 10);
    }
}
