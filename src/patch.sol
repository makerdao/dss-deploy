pragma solidity ^0.4.24;

import {Pit} from "dss/frob.sol";

import {Spotter} from "./poke.sol";

import {SpotFab} from "./DssDeploy.sol";

contract Patch04 {
    Spotter public spotter;

    function upgrade_eth_spotter(SpotFab spotFab, Pit pit, address pip, address mom) public {
        spotter = spotFab.newSpotter(pit, bytes32("ETH"));
        spotter.file(address(pip)); // Set pip
        spotter.file(uint(1.5 * 10 ** 27)); // Set mat
        pit.rely(spotter);
        spotter.rely(mom);
        spotter.poke();
    }
}
