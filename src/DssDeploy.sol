pragma solidity ^0.4.24;

import {DSToken} from "ds-token/token.sol";
import {DSAuth, DSAuthority} from "ds-auth/auth.sol";

import {Vat} from "dss/tune.sol";
import {Pit} from "dss/frob.sol";
import {Drip} from "dss/drip.sol";
import {Vow} from "dss/heal.sol";
import {Cat} from "dss/bite.sol";
import {DaiAdapter} from "dss/join.sol";
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
    function newFlip(Vat vat, bytes32 ilk) public returns (Flipper flop) {
        flop = new Flipper(vat, ilk);
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
    Flapper public flap;
    Flopper public flop;
    DaiMom public mom;
    mapping(bytes32 => Ilk) public ilks;

    uint8 public step = 0;

    uint256 constant ONE = 10 ** 27;

    struct Ilk {
        Flipper flip;
        address adapter;
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
        flapFab = flapFab_;
        flopFab = flopFab_;
        momFab = momFab_;
        flipFab = flipFab_;
        priceFab = priceFab_;
    }

    function deployContracts(address gov) public auth {
        require(step == 0);
        vat = vatFab.newVat();
        pit = pitFab.newPit(vat);
        drip = dripFab.newDrip(vat);
        vow = vowFab.newVow();
        cat = catFab.newCat(vat, pit, vow);
        dai = tokenFab.newToken("DAI");
        daiApt = daiAptFab.newDaiApt(vat, dai);
        flap = flapFab.newFlap(daiApt, gov); // TODO: Check if pass adapter or token
        flop = flopFab.newFlop(daiApt, gov); // TODO: Check if pass adapter or token
        mom = momFab.newMom();

        vow.file("vat", vat);
        vow.file("flap", flap);
        vow.file("flop", flop);
        pit.file("drip", drip);

        // Internal auth
        vat.rely(drip);
        vat.rely(pit);
        vat.rely(cat);
        vat.rely(daiApt);
        vat.rely(flap);
        vat.rely(flop);
        vow.rely(cat);
        flop.rely(vow);

        step += 1;
    }

    function deployIlk(bytes32 ilk, address adapter, address pip) public auth {
        require(step > 0);
        ilks[ilk].flip = flipFab.newFlip(vat, ilk);
        ilks[ilk].adapter = adapter;
        ilks[ilk].price = priceFab.newPrice(pit, ilk);
        ilks[ilk].price.file(pip); // Set pip
        ilks[ilk].price.file(ONE); // Set mat
        cat.fuss(ilk, ilks[ilk].flip);
        cat.file(ilk, "chop", ONE);
        vat.init(ilk);
        drip.file(ilk, bytes32(address(vow)), ONE);

        // Internal auth
        vat.rely(ilks[ilk].flip);
        vat.rely(adapter);
        pit.rely(ilks[ilk].price);
        ilks[ilk].price.rely(mom);

        ilks[ilk].price.poke();
    }

    function configParams() public auth {
        require(step == 1);
        step += 1;
    }

    function verifyParams() public auth {
        require(step == 2);
        step += 1;
    }

    function configAuth(DSAuthority authority) public auth {
        require(step == 3);
        pit.rely(mom);
        cat.rely(mom);
        vow.rely(mom);
        drip.rely(mom);

        mom.setAuthority(authority);
        mom.setOwner(0);
        this.setAuthority(authority);
        this.setOwner(0);

        step += 1;
    }
}
