pragma solidity ^0.4.24;

import {Vat} from "dss/tune.sol";
import {Cat} from "dss/bite.sol";
import {Pit} from "dss/frob.sol";
import {Flipper} from "dss/flip.sol";

import {Spotter} from "./poke.sol";

import {FlipFab, SpotFab} from "./DssDeploy.sol";

contract Patch05 {
    Spotter public spotter;
    Flipper public flip;

    function add_rep_collateral(
        FlipFab flipFab,
        SpotFab spotFab,
        Vat vat,
        Cat cat,
        Pit pit,
        address daiMove,
        address mover,
        address adapter,
        address pip,
        address mom
    ) public {
        // Deploy
        flip = flipFab.newFlip(daiMove, mover);
        spotter = spotFab.newSpotter(pit, "REP");
        spotter.file(pip); // Set pip
        spotter.file(uint(1.7 * 10 ** 27)); // Set liq ratio

        // Internal references set up
        cat.file("REP", "flip", flip);
        cat.file("REP", "lump", uint(10000 ether)); // 10000 DAI per batch
        cat.file("REP", "chop", uint(10 ** 27));
        pit.file("REP", "line", uint(2000000 ether)); // Set debt ceiling
        // vat.init("REP");

        // Internal auth
        vat.rely(flip);
        vat.rely(adapter);
        vat.rely(mover);
        pit.rely(spotter);
        spotter.rely(mom);

        // Update spotter
        spotter.poke();
    }
}
