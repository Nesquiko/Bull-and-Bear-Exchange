// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {DeployConfig} from "./DeployConfig.s.sol";
import {BBToken} from "../src/BBToken.sol";
import {BBExchange} from "../src/BBExchange.sol";

contract DeployContracts is Script {
    function run() external returns (BBToken token, BBExchange exchange, address owner) {
        DeployConfig config = new DeployConfig();
        (, uint256 deployerPK) = config.activeConfig();
        owner = vm.addr(deployerPK);

        vm.startBroadcast(deployerPK);
        token = new BBToken(owner);
        exchange = new BBExchange(address(token), owner);
        vm.stopBroadcast();
        return (token, exchange, owner);
    }
}