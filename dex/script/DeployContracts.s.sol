// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DeployConfig} from "./DeployConfig.s.sol";
import {BBToken} from "../src/BBToken.sol";
import {BBExchange} from "../src/BBExchange.sol";

contract DeployContracts is Script {
    uint256 private constant BB_TOKEN_SUPPLY = 5000;

    function run() external returns (BBToken token, BBExchange exchange, address owner) {
        DeployConfig config = new DeployConfig();
        (, uint256 deployerPK) = config.activeConfig();
        owner = vm.addr(deployerPK);

        vm.startBroadcast(deployerPK);
        token = new BBToken(BB_TOKEN_SUPPLY);
        exchange = new BBExchange(address(token), owner);
        vm.stopBroadcast();
        return (token, exchange, owner);
    }
}
