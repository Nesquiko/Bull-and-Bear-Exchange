// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BBToken} from "../src/BBToken.sol";
import {BBExchange} from "../src/BBExchange.sol";
import {DeployContracts} from "../script/DeployContracts.s.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract BBExchangeTest is Test {
    uint256 private constant BB_TOKEN_SUPPLY = 5_000;
    uint256 private constant USERS_BALANCE = 10_000 wei;

    DeployContracts deployer;
    BBToken token;
    BBExchange exchange;
    address user;

    /// @notice Creates user with balance of `USERS_BALANCE` ether
    /// @notice Deploys token with user's balance of `BB_TOKEN_SUPPLY`,
    ///     and deployes exchange with the address of the token
    function setUp() public {
        user = makeAddr("user");
        vm.deal(user, USERS_BALANCE);
        deployer = new DeployContracts();
        (token, exchange) = deployer.deployContracts(user, BB_TOKEN_SUPPLY);
    }

    function testCreatePoolNoEthProvided() public {
        uint256 tokenLiquidity = 5_000;
        uint256 ethLiquidity = 0;
        vm.prank(user);
        vm.expectRevert(bytes("Need eth to create pool."));
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);
    }

    function testCreatePoolProvideMoreTokensThanBalanceAllows() public {
        uint256 tokenLiquidity = 5_000 + 1;
        uint256 ethLiquidity = 5000;
        vm.prank(user);
        vm.expectRevert(bytes("Not have enough tokens to create the pool"));
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);
    }

    function testCreatePoolProvideNoTokens() public {
        uint256 tokenLiquidity = 0;
        uint256 ethLiquidity = 5000;
        vm.prank(user);
        vm.expectRevert(bytes("Need tokens to create pool."));
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);
    }

    function testCreatePoolTokenReservesCorrectlySet() public {
        uint256 tokenLiquidity = 5_000;
        uint256 ethLiquidity = 5_000;
        createAllowance(user, address(exchange), tokenLiquidity);
        vm.prank(user);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        assertEq(tokenLiquidity, exchange.tokenReserves());
        assertEq(tokenLiquidity, token.balanceOf(address(exchange)));
    }

    function testCreatePoolEthReservesCorrectlySet() public {
        uint256 tokenLiquidity = 5_000;
        uint256 ethLiquidity = 5_000;
        createAllowance(user, address(exchange), tokenLiquidity);
        vm.prank(user);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        assertEq(ethLiquidity, exchange.ethReserves());
        assertEq(ethLiquidity, address(exchange).balance);
    }

    function testCreatePoolKCorrectlySet() public {
        uint256 tokenLiquidity = 5_000;
        uint256 ethLiquidity = 5_000;
        uint256 k = tokenLiquidity * ethLiquidity;
        createAllowance(user, address(exchange), tokenLiquidity);
        vm.prank(user);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        assertEq(k, exchange.k());
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

    function createAllowance(address owner, address spender, uint256 amount) public {
        vm.prank(owner);
        token.approve(spender, amount);
    }
}
