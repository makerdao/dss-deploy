pragma solidity ^0.4.24;

import {Vat} from "dss/tune.sol";
import {Cat} from "dss/bite.sol";
import {Vow} from "dss/heal.sol";

import {CatFab, VowFab} from "./DssDeploy.sol";

contract Patch03 {
    Cat public cat;
    Vow public vow;

    function upgrade_vow(VowFab fab, address vat, address flap, address flop, address mom) public {
        vow = fab.newVow();

        vow.file("vat",  vat);
        vow.file("flap", flap);
        vow.file("flop", flop);

        vow.file("bump", uint(10000 ether));
        vow.file("sump", uint(10000 ether));

        vow.rely(mom);
    }
    function upgrade_cat(CatFab fab, address vat, address pit, address flip, address mom) public {
        require(address(vow) != address(0));

        cat = fab.newCat(Vat(vat));

        cat.file("vow", vow);
        cat.file("pit", pit);

        cat.file("ETH", "flip", flip);
        cat.file("ETH", "chop", uint(1.1E27));
        cat.file("ETH", "lump", uint(10000 ether));

        vow.rely(cat);
        cat.rely(mom);
    }
}
