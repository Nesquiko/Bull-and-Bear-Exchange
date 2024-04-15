// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DeployConfig} from "./DeployConfig.s.sol";
import {BBToken} from "../src/BBToken.sol";
import {BBExchange} from "../src/BBExchange.sol";

contract DeployContracts is Script {
    uint256 private constant BB_TOKEN_SUPPLY = 5_000;

    function run() external returns (BBToken token, BBExchange exchange, address owner) {
        DeployConfig config = new DeployConfig();
        (, uint256 deployerPK) = config.activeConfig();
        owner = vm.rememberKey(deployerPK);

        token = deployToken(BB_TOKEN_SUPPLY, owner);
        exchange = deployExchange(address(token), owner);
        return (token, exchange, owner);
    }

    function deployContracts(address deployer, uint256 tokenSupply)
        external
        returns (BBToken token, BBExchange exchange)
    {
        token = deployToken(tokenSupply, deployer);
        exchange = deployExchange(address(token), deployer);
        return (token, exchange);
    }

    function deployToken(uint256 supply, address deployer) public returns (BBToken) {
        vm.startBroadcast(deployer);
        BBToken token = new BBToken(supply);
        vm.stopBroadcast();
        return token;
    }

    function deployExchange(address token, address deployer) public returns (BBExchange) {
        vm.startBroadcast(deployer);
        BBExchange exchange = new BBExchange(token, deployer);
        vm.stopBroadcast();
        return exchange;
    }
}
