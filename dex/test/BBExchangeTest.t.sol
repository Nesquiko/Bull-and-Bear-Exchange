// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BBToken} from "../src/BBToken.sol";
import {BBExchange} from "../src/BBExchange.sol";
import {DeployContracts} from "../script/DeployContracts.s.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {BBLibrary} from "../src/BBLibrary.sol";

contract BBExchangeTest is Test {
    uint256 private constant BB_TOKEN_SUPPLY = 7_000;
    uint256 private constant LP_TOKEN_BALANCE = 5_000;
    uint256 private constant LP2_TOKEN_BALANCE = 1_000;
    uint256 private constant SWAPPERS_TOKEN_BALANCE = BB_TOKEN_SUPPLY - LP_TOKEN_BALANCE - LP2_TOKEN_BALANCE;
    uint256 private constant LP_WEI_BALANCE = 10_000 wei;
    uint256 private constant SWAPPERS_WEI_BALANCE = LP_WEI_BALANCE;

    DeployContracts deployer;
    BBToken token;
    BBExchange exchange;
    address lp;
    address lp2;
    address swapper;

    modifier initializedExchange(uint256 liquidityAmount, address owner) {
        createAllowance(owner, address(exchange), liquidityAmount);
        vm.prank(owner);
        exchange.createPool{value: liquidityAmount}(liquidityAmount);
        _;
    }

    modifier swapWeiForTokens(address _swapper, uint256 weiAmount, uint256 minAmount) {
        vm.prank(_swapper);
        exchange.swapETHForTokens{value: weiAmount}(minAmount);
        _;
    }

    modifier swapTokensForEth(address _swapper, uint256 tokenAmount, uint256 minAmount) {
        createAllowance(_swapper, address(exchange), tokenAmount);
        vm.prank(_swapper);
        exchange.swapTokensForETH(tokenAmount, minAmount);
        _;
    }

    /// @notice Creates lp with balance of `LP_WEI_BALANCE` wei
    /// @notice Deploys token with supply of `BB_TOKEN_SUPPLY`
    /// @notice gives `LP_TOKEN_BALANCE` BBTokens to lp
    /// @notice gives `LP2_TOKEN_BALANCE` BBTokens to lp2
    /// @notice gives `SWAPPERS_TOKEN_BALANCE` BBTokens to swapper
    /// @notice deployes exchange with the address of the token
    function setUp() public {
        lp = makeAddr("lp");
        vm.deal(lp, LP_WEI_BALANCE);
        deployer = new DeployContracts();
        (token, exchange) = deployer.deployContracts(lp, BB_TOKEN_SUPPLY);

        lp2 = makeAddr("lp2");
        vm.deal(lp2, LP_WEI_BALANCE);
        vm.prank(lp);
        token.transfer(lp2, LP2_TOKEN_BALANCE);

        swapper = makeAddr("swapper");
        vm.deal(swapper, SWAPPERS_WEI_BALANCE);
        vm.prank(lp);
        token.transfer(swapper, SWAPPERS_TOKEN_BALANCE);
    }

    function testAddLiquidityWeiAppreciatedCorrectLiquidityAdded()
        public
        initializedExchange(LP_TOKEN_BALANCE, lp)
        swapTokensForEth(swapper, 500, 400)
    {
        createAllowance(lp2, address(exchange), LP2_TOKEN_BALANCE);
        uint256 expectedLiquidity = 82 * exchange.totalLiquidity() / exchange.weiReserves();
        uint256 expectedTotalLiquidity = exchange.totalLiquidity() + expectedLiquidity;

        vm.prank(lp2);
        exchange.addLiquidity{value: 100}(80, 100, 80);

        assertEq(expectedLiquidity, exchange.lpLiquidity(lp2));
        assertEq(expectedTotalLiquidity, exchange.totalLiquidity());
        assertEq(lp2, exchange.lpAt(1));
    }

    function testAddLiquidityWeiAppreciatedProvideLiquidity()
        public
        initializedExchange(LP_TOKEN_BALANCE, lp)
        swapTokensForEth(swapper, 500, 400)
    {
        createAllowance(lp2, address(exchange), LP2_TOKEN_BALANCE);
        vm.prank(lp2);
        exchange.addLiquidity{value: 100}(80, 100, 80);

        uint256 expectedWeiProvided = 82;
        uint256 expectedWeiReserves = LP_TOKEN_BALANCE - 442 + expectedWeiProvided;
        uint256 expectedTokenReserves = LP_TOKEN_BALANCE + 500 + 100;
        uint256 expectedK = expectedWeiReserves * expectedTokenReserves;

        assertEq(expectedWeiReserves, exchange.weiReserves());
        assertEq(expectedTokenReserves, exchange.tokenReserves());
        assertEq(lp2.balance, LP_WEI_BALANCE - expectedWeiProvided);
        assertEq(token.balanceOf(lp2), LP2_TOKEN_BALANCE - 100);
        assertEq(expectedK, exchange.k());
    }

    function testAddLiquidityTokenAppreciatedProvideLiquidity()
        public
        initializedExchange(LP_TOKEN_BALANCE, lp)
        swapWeiForTokens(swapper, 500, 400)
    {
        createAllowance(lp2, address(exchange), LP2_TOKEN_BALANCE);
        vm.prank(lp2);
        exchange.addLiquidity{value: 100}(80, 100, 80);

        uint256 expectedTokenProvided = 82;
        uint256 expectedWeiReserves = LP_TOKEN_BALANCE + 500 + 100;
        uint256 expectedTokenReserves = LP_TOKEN_BALANCE - 442 + expectedTokenProvided;
        uint256 expectedK = expectedWeiReserves * expectedTokenReserves;

        assertEq(expectedWeiReserves, exchange.weiReserves());
        assertEq(expectedTokenReserves, exchange.tokenReserves());
        assertEq(lp2.balance, LP_WEI_BALANCE - 100);
        assertEq(token.balanceOf(lp2), LP2_TOKEN_BALANCE - expectedTokenProvided);
        assertEq(expectedK, exchange.k());
    }

    function testAddLiquidityWeiQuoteBellowMin()
        public
        initializedExchange(LP_TOKEN_BALANCE, lp)
        swapTokensForEth(swapper, 500, 400)
    {
        createAllowance(lp2, address(exchange), LP2_TOKEN_BALANCE);
        vm.expectRevert(bytes("wei quote bellow min"));
        vm.prank(lp2);
        exchange.addLiquidity{value: 100}(85, 100, 85);
    }

    function testAddLiquidityTokenQuoteBellowMin()
        public
        initializedExchange(LP_TOKEN_BALANCE, lp)
        swapWeiForTokens(swapper, 500, 400)
    {
        createAllowance(lp2, address(exchange), LP2_TOKEN_BALANCE);
        vm.expectRevert(bytes("token quote bellow min"));
        vm.prank(lp2);
        exchange.addLiquidity{value: 100}(85, 100, 85);
    }

    function testAddLiquidityTokenTransferNotAllowed() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Not enough token allowed for transfer"));
        vm.prank(lp2);
        exchange.addLiquidity{value: LP_WEI_BALANCE}(LP_WEI_BALANCE, LP2_TOKEN_BALANCE, LP2_TOKEN_BALANCE);
    }

    function testAddLiquidityInsufficientTokenBalance() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Not enough tokens"));
        vm.prank(lp2);
        exchange.addLiquidity{value: LP_WEI_BALANCE}(LP_WEI_BALANCE, LP2_TOKEN_BALANCE + 1, LP2_TOKEN_BALANCE);
    }

    function testAddLiquidityMinTokenAmountBellowAmount() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("minTokenAmount can't be less than tokenAmount"));
        vm.prank(lp2);
        exchange.addLiquidity{value: LP_WEI_BALANCE}(LP_WEI_BALANCE, LP2_TOKEN_BALANCE, LP2_TOKEN_BALANCE + 1);
    }

    function testAddLiquidityNoTokens() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("No tokens provided"));
        vm.prank(lp2);
        exchange.addLiquidity{value: LP_WEI_BALANCE}(LP_WEI_BALANCE, 0, 0);
    }

    function testAddLiquidityMinWeiAmountBellowAmount() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("minWeiAmount can't be more than msg.value"));
        vm.prank(lp2);
        exchange.addLiquidity{value: 10}(11, 0, 0);
    }

    function testAddLiquidityNoEth() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("No ETH provided"));
        vm.prank(lp2);
        exchange.addLiquidity{value: 0}(0, 0, 0);
    }

    function testRemoveLiquidityNoEth() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Amount must be greater than zero"));
        vm.prank(lp);
        exchange.removeLiquidity(0);
    }

    function testRemoveLiquidityNotEnoughLiquidity() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Not enough liquidity"));
        vm.prank(lp);
        exchange.removeLiquidity(1000000);
    }

//    TODO: No liquidity found for sender
//    TODO: Insufficient liquidity

    function testSwapETHForTokensTransferTokens() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        exchange.swapETHForTokens{value: swapAmount}(90);

        assertEq(token.balanceOf(swapper), SWAPPERS_TOKEN_BALANCE + 95);
    }

    function testSwapETHForTokensUpdateReserves() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        exchange.swapETHForTokens{value: swapAmount}(90);

        uint256 expectedWeiReserves = LP_TOKEN_BALANCE + swapAmount;
        uint256 expectedTokenReserves = LP_TOKEN_BALANCE - 95;

        assertEq(expectedTokenReserves, exchange.tokenReserves());
        assertEq(expectedWeiReserves, exchange.weiReserves());
    }

    function testSwapETHForTokensTooMuchSlippage() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        vm.expectRevert(bytes("Too much slippage"));
        exchange.swapETHForTokens{value: swapAmount}(96);
    }

    function testSwapETHForTokensNotEnoughLiquidity() public initializedExchange(2, lp) {
        vm.expectRevert(bytes("Not enough liquidity"));
        vm.prank(swapper);
        exchange.swapETHForTokens{value: 2}(0);
    }

    function testSwapETHForTokensNoETH() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Need ETH to swap"));
        vm.prank(swapper);
        exchange.swapETHForTokens{value: 0}(0);
    }

    function testSwapTokensForETHTransferEth() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        exchange.swapTokensForETH(swapAmount, 95);

        assertEq(swapper.balance, SWAPPERS_WEI_BALANCE + 95);
    }

    function testSwapTokensForETHUpdateReserves() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        exchange.swapTokensForETH(swapAmount, 95);

        uint256 expectedTokenReserves = LP_TOKEN_BALANCE + swapAmount;
        uint256 expectedWeiReserves = LP_TOKEN_BALANCE - 95;

        assertEq(expectedTokenReserves, exchange.tokenReserves());
        assertEq(expectedWeiReserves, exchange.weiReserves());
    }

    function testSwapTokensForETHTransferTokens() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        exchange.swapTokensForETH(swapAmount, 95);

        assertEq(SWAPPERS_TOKEN_BALANCE - swapAmount, token.balanceOf(swapper));
        assertEq(LP_TOKEN_BALANCE + swapAmount, token.balanceOf(address(exchange)));
    }

    function testSwapTokensForETHTooMuchSlippage() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        uint256 swapAmount = 100;
        vm.prank(swapper);
        vm.expectRevert(bytes("Too much slippage"));
        exchange.swapTokensForETH(swapAmount, 96);
    }

    function testSwapTokensForETHNotEnoughLiquidity() public initializedExchange(2, lp) {
        createAllowance(swapper, address(exchange), SWAPPERS_TOKEN_BALANCE);
        vm.expectRevert(bytes("Not enough liquidity"));
        vm.prank(swapper);
        exchange.swapTokensForETH(2, 0);
    }

    function testSwapTokensForETHProvidedMoreTokensThanAllowed() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Not enough token allowed for transfer"));
        vm.prank(swapper);
        exchange.swapTokensForETH(SWAPPERS_TOKEN_BALANCE, 0);
    }

    function testSwapTokensForETHProvidedMoreTokensThanBalanceAllows()
        public
        initializedExchange(LP_TOKEN_BALANCE, lp)
    {
        vm.expectRevert(bytes("Not enough tokens"));
        vm.prank(swapper);
        exchange.swapTokensForETH(SWAPPERS_TOKEN_BALANCE + 1, 0);
    }

    function testSwapTokensForETHNoTokens() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Need tokens to swap"));
        vm.prank(swapper);
        exchange.swapTokensForETH(0, 0);
    }

    function testGetTokenAmountCorrect() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        (uint256 tokenAmount, uint256 withFee) = exchange.getTokenAmount(100);
        assertEq(tokenAmount, 98);
        assertEq(withFee, 95);
    }

    function testGetTokenAmountZeroWeiAmount() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Wei amount must be greater than zero"));
        exchange.getTokenAmount(0);
    }

    function testGetTokenAmountPoolNotInitialized() public {
        vm.expectRevert(bytes("Invalid reserves"));
        exchange.getTokenAmount(1);
    }

    function testGetWeiAmountCorrect() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        (uint256 weiAmount, uint256 withFee) = exchange.getWeiAmount(100);
        assertEq(weiAmount, 98);
        assertEq(withFee, 95);
    }

    function testGetWeiAmountZeroTokenAmount() public initializedExchange(LP_TOKEN_BALANCE, lp) {
        vm.expectRevert(bytes("Token amount must be greater than zero"));
        exchange.getWeiAmount(0);
    }

    function testGetWeiAmountPoolNotInitialized() public {
        vm.expectRevert(bytes("Invalid reserves"));
        exchange.getWeiAmount(1);
    }

    function testCreatePoolNoEthProvided() public {
        uint256 tokenLiquidity = LP_TOKEN_BALANCE;
        uint256 ethLiquidity = 0;
        vm.prank(lp);
        vm.expectRevert(bytes("Need eth to create pool."));
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);
    }

    function testCreatePoolProvideMoreTokensThanBalanceAllows() public {
        uint256 tokenLiquidity = LP_TOKEN_BALANCE + 1;
        uint256 ethLiquidity = 5_000;
        vm.prank(lp);
        vm.expectRevert(bytes("Not have enough tokens to create the pool"));
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);
    }

    function testCreatePoolProvideNoTokens() public {
        uint256 tokenLiquidity = 0;
        uint256 ethLiquidity = 5_000;
        vm.prank(lp);
        vm.expectRevert(bytes("Need tokens to create pool."));
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);
    }

    function testCreatePoolTokenReservesCorrectlySet() public {
        uint256 tokenLiquidity = LP_TOKEN_BALANCE;
        uint256 ethLiquidity = 5_000;
        createAllowance(lp, address(exchange), tokenLiquidity);
        vm.prank(lp);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        assertEq(tokenLiquidity, exchange.tokenReserves());
        assertEq(tokenLiquidity, token.balanceOf(address(exchange)));
    }

    function testCreatePoolEthReservesCorrectlySet() public {
        uint256 tokenLiquidity = LP_TOKEN_BALANCE;
        uint256 ethLiquidity = 5_000;
        createAllowance(lp, address(exchange), tokenLiquidity);
        vm.prank(lp);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        assertEq(ethLiquidity, exchange.weiReserves());
        assertEq(ethLiquidity, address(exchange).balance);
    }

    function testCreatePoolKCorrectlySet() public {
        uint256 tokenLiquidity = LP_TOKEN_BALANCE;
        uint256 ethLiquidity = 5_000;
        uint256 k = tokenLiquidity * ethLiquidity;
        createAllowance(lp, address(exchange), tokenLiquidity);
        vm.prank(lp);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        assertEq(k, exchange.k());
    }

    function testCreatePoolAddLiquidityToCreator() public {
        uint256 tokenLiquidity = LP_TOKEN_BALANCE;
        uint256 ethLiquidity = 5_000;
        createAllowance(lp, address(exchange), tokenLiquidity);
        vm.prank(lp);
        exchange.createPool{value: ethLiquidity}(tokenLiquidity);

        uint256 expectedLiquidity = 4999; // 5000 - MIN_LIQUIDITY
        assertEq(expectedLiquidity, exchange.lpLiquidity(lp));
        assertEq(lp, exchange.lpAt(0));
        assertEq(expectedLiquidity, exchange.totalLiquidity());
    }

    function createAllowance(address owner, address spender, uint256 amount) public {
        vm.prank(owner);
        token.approve(spender, amount);
    }

    /// @notice An example on how to use different Foundry test functions
    /// @dev more can be found at https://book.getfoundry.sh/
    function testExample() public {
        address user = makeAddr("user");
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
