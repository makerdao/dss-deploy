pragma solidity ^0.4.24;

import "ds-auth/auth.sol";

import {Cat} from "dss/bite.sol";
import {Vat} from "dss/tune.sol";
import {Vow} from "dss/heal.sol";

import {CatFab, VowFab, DssDeploy} from "./DssDeploy.sol";
import {DaiMom} from "./mom.sol";

contract Patch00 is DSAuth {
    DssDeploy public deploy;

    Cat    public cat;
    Vow    public vow;
    CatFab public catfab;
    VowFab public vowfab;

    constructor(address deploy_) public {
        deploy = DssDeploy(deploy_);
    }

    function upgrade_vow(VowFab fab) public auth {
        vow = fab.newVow();

        vow.file("vat",  deploy.vat());
        vow.file("flap", deploy.flap());
        vow.file("flop", deploy.flop());

        vow.rely(deploy.mom());
    }
    function upgrade_cat(CatFab fab) public auth {
        require(address(vow) != address(0));

        cat = fab.newCat(deploy.vat());

        cat.file("vow", vow);
        cat.file("pit", deploy.pit());

        (address flip, address join, address move, address spotter) = deploy.ilks("ETH");
        join; move; spotter;

        cat.file("ETH", "flip", flip);
        cat.file("ETH", "chop", uint(1E27));

        vow.rely(cat);
        vow.rely(deploy.mom());
        cat.rely(deploy.mom());
    }
    function apply() public auth {
        require(address(vow) != address(0));
        require(address(cat) != address(0));

        DaiMom mom = deploy.mom();

        // enable auctions with non-zero lot size
        mom.file(cat, "ETH", "lump", uint(10000 ether));
        mom.file(vow, "bump", uint(10000 ether));
        mom.file(vow, "sump", uint(10000 ether));

        // set liquidation ratio to 150%
        (address flip, address join, address move, address spotter) = deploy.ilks("ETH");
        flip; join; move;
        mom.file(spotter, uint(1.5E27));

        // set liquidation penalty to 10%
        mom.file(cat, "ETH", "chop", uint(1.1E27));

        // permit the vow to heal
        deploy.rely(this);
        Vat vat = deploy.vat();
        vat.rely(vow);
    }
}
