pragma solidity ^0.4.24;

import {DSToken} from "ds-token/token.sol";
import {DSAuth, DSAuthority} from "ds-auth/auth.sol";

import {Vat} from "dss/tune.sol";
import {Pit} from "dss/frob.sol";
import {Drip} from "dss/drip.sol";
import {Vow} from "dss/heal.sol";
import {Cat} from "dss/bite.sol";
import {DaiAdapter} from "dss/join.sol";
import {DaiMove} from "dss/move.sol";
import {Flapper} from "dss/flap.sol";
import {Flopper} from "dss/flop.sol";
import {Flipper} from "dss/flip.sol";

import {Price} from "./poke.sol";
import {DaiMom} from "./mom.sol";

contract VatFab {
    function newVat() public returns (Vat vat) {
        vat = new Vat();
        vat.rely(msg.sender);
    }
}

contract PitFab {
    function newPit(Vat vat) public returns (Pit pit) {
        pit = new Pit(vat);
        pit.rely(msg.sender);
    }
}

contract DripFab {
    function newDrip(Vat vat) public returns (Drip drip) {
        drip = new Drip(vat);
        drip.rely(msg.sender);
    }
}

contract VowFab {
    function newVow() public returns (Vow vow) {
        vow = new Vow();
        vow.rely(msg.sender);
    }
}

contract CatFab {
    function newCat(Vat vat, Pit pit, Vow vow) public returns (Cat cat) {
        cat = new Cat(vat, pit, vow);
        cat.rely(msg.sender);
    }
}

contract TokenFab {
    function newToken(bytes32 symbol) public returns (DSToken token) {
        token = new DSToken(symbol);
        token.setOwner(msg.sender);
    }
}

contract DaiAptFab {
    function newDaiApt(Vat vat, address dai) public returns (DaiAdapter daiApt) {
        daiApt = new DaiAdapter(vat, dai);
    }
}

contract DaiMoveFab {
    function newDaiMove(Vat vat) public returns (DaiMove daiMove) {
        daiMove = new DaiMove(vat);
    }
}

contract FlapFab {
    function newFlap(address dai, address gov) public returns (Flapper flap) {
        flap = new Flapper(dai, gov);
    }
}

contract FlopFab {
    function newFlop(address dai, address gov) public returns (Flopper flop) {
        flop = new Flopper(dai, gov);
        flop.rely(msg.sender);
    }
}

contract FlipFab {
    function newFlip(address dai, address gem) public returns (Flipper flop) {
        flop = new Flipper(dai, gem);
    }
}

contract PriceFab {
    function newPrice(Pit pit, bytes32 ilk) public returns (Price price) {
        price = new Price(pit, ilk);
        price.rely(msg.sender);
    }
}

contract MomFab {
    function newMom() public returns (DaiMom mom) {
        mom = new DaiMom();
        mom.setOwner(msg.sender);
    }
}

contract DssDeploy is DSAuth {
    VatFab public vatFab;
    PitFab public pitFab;
    DripFab public dripFab;
    VowFab public vowFab;
    CatFab public catFab;
    TokenFab public tokenFab;
    DaiAptFab public daiAptFab;
    DaiMoveFab public daiMoveFab;
    FlapFab public flapFab;
    FlopFab public flopFab;
    MomFab public momFab;
    FlipFab public flipFab;
    PriceFab public priceFab;

    Vat public vat;
    Pit public pit;
    Drip public drip;
    Vow public vow;
    Cat public cat;
    DSToken public dai;
    DaiAdapter public daiApt;
    DaiMove public daiMove;
    Flapper public flap;
    Flopper public flop;
    DaiMom public mom;
    mapping(bytes32 => Ilk) public ilks;

    uint8 public step = 0;

    uint256 constant ONE = 10 ** 27;

    struct Ilk {
        Flipper flip;
        address adapter;
        address mover;
        Price price;
    }

    constructor(
        VatFab vatFab_,
        PitFab pitFab_,
        DripFab dripFab_,
        VowFab vowFab_,
        CatFab catFab_,
        TokenFab tokenFab_,
        DaiAptFab daiAptFab_,
        DaiMoveFab daiMoveFab_,
        FlapFab flapFab_,
        FlopFab flopFab_,
        MomFab momFab_,
        FlipFab flipFab_,
        PriceFab priceFab_
    ) public {
        vatFab = vatFab_;
        pitFab = pitFab_;
        dripFab = dripFab_;
        vowFab = vowFab_;
        catFab = catFab_;
        tokenFab = tokenFab_;
        daiAptFab = daiAptFab_;
        daiMoveFab = daiMoveFab_;
        flapFab = flapFab_;
        flopFab = flopFab_;
        momFab = momFab_;
        flipFab = flipFab_;
        priceFab = priceFab_;
    }

    function deployVat() public auth {
        require(vat == address(0), "VAT already deployed");
        vat = vatFab.newVat();
    }

    function deployPit() public auth {
        require(vat != address(0), "Missing VAT deployment");
        pit = pitFab.newPit(vat);

        // Internal auth
        vat.rely(pit);
    }

    function deployDai() public auth {
        require(vat != address(0), "Missing VAT deployment");

        // Deploy
        dai     = tokenFab.newToken("DAI");
        daiApt  = daiAptFab.newDaiApt(vat, dai);
        daiMove = daiMoveFab.newDaiMove(vat);

        // Internal auth
        vat.rely(daiApt);
        vat.rely(daiMove);
    }

    function deployTaxation(address gov) public auth {
        require(gov != address(0), "Missing GOV address");
        require(vat != address(0), "Missing VAT deployment");
        require(pit != address(0), "Missing PIT deployment");

        // Deploy
        vow = vowFab.newVow();
        drip = dripFab.newDrip(vat);
        flap = flapFab.newFlap(daiMove, gov);

        // Internal references set up
        pit.file("drip", drip);
        vow.file("vat", vat);
        vow.file("flap", flap);

        // Internal auth
        vat.rely(drip);
        vat.rely(flap);
    }

    function deployLiquidation(address gov) public auth {
        require(vat != address(0), "Missing VAT deployment");
        require(pit != address(0), "Missing PIT deployment");
        require(vow != address(0), "Missing VOW deployment");

        // Deploy
        cat = catFab.newCat(vat, pit, vow);
        flop = flopFab.newFlop(daiMove, gov);

        // Internal references set up
        vow.file("flop", flop);

        // Internal auth
        vat.rely(cat);
        vat.rely(flop);
        vow.rely(cat);
        flop.rely(vow);
    }

    function deployMom(DSAuthority authority) public auth {
        require(pit != address(0), "Missing PIT deployment");
        require(vow != address(0), "Missing VOW deployment");
        require(drip != address(0), "Missing DRIP deployment");
        require(cat != address(0), "Missing CAT deployment");

        // Auth
        mom = momFab.newMom();
        pit.rely(mom);
        cat.rely(mom);
        vow.rely(mom);
        drip.rely(mom);
        mom.setAuthority(authority);
        mom.setOwner(0);
        this.setAuthority(authority);
        this.setOwner(0);
    }

    function deployCollateral(bytes32 ilk, address adapter, address mover, address pip) public auth {
        require(ilk != bytes32(""), "Missing ilk name");
        require(adapter != address(0), "Missing adapter address");
        require(mover   != address(0), "Missing mover address");
        require(pip != address(0), "Missing PIP address");
        require(vat != address(0), "Missing VAT deployment");
        require(cat != address(0), "Missing VAT deployment");

        // Deploy
        ilks[ilk].flip = flipFab.newFlip(daiMove, mover);
        ilks[ilk].adapter = adapter;
        ilks[ilk].mover = mover;
        ilks[ilk].price = priceFab.newPrice(pit, ilk);
        ilks[ilk].price.file(pip); // Set pip
        ilks[ilk].price.file(ONE); // Set mat

        // Internal references set up
        cat.file(ilk, "flip", ilks[ilk].flip);
        cat.file(ilk, "chop", ONE);
        vat.init(ilk);
        drip.file(ilk, bytes32(address(vow)), ONE);

        // Internal auth
        vat.rely(ilks[ilk].flip);
        vat.rely(adapter);
        vat.rely(mover);
        pit.rely(ilks[ilk].price);
        ilks[ilk].price.rely(mom);

        // Update price
        ilks[ilk].price.poke();
    }
}
