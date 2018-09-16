pragma solidity ^0.4.24;

import {DSToken} from "ds-token/token.sol";
import {DSAuth, DSAuthority} from "ds-auth/auth.sol";
import {DSGuard} from "ds-guard/guard.sol";
import {DSProxy, DSProxyCache} from "ds-proxy/proxy.sol";

import {Vat} from "dss/tune.sol";
import {Pit} from "dss/frob.sol";
import {Drip} from "dss/drip.sol";
import {Vow} from "dss/heal.sol";
import {Cat} from "dss/bite.sol";
import {DaiJoin} from "dss/join.sol";
import {DaiMove} from "dss/move.sol";
import {Flapper} from "dss/flap.sol";
import {Flopper} from "dss/flop.sol";
import {Flipper} from "dss/flip.sol";

import {Spotter} from "./poke.sol";

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
    function newCat(Vat vat) public returns (Cat cat) {
        cat = new Cat(vat);
        cat.rely(msg.sender);
    }
}

contract TokenFab {
    function newToken(bytes32 symbol) public returns (DSToken token) {
        token = new DSToken(symbol);
        token.setOwner(msg.sender);
    }
}

contract GuardFab {
    function newGuard() public returns (DSGuard guard) {
        guard = new DSGuard();
        guard.setOwner(msg.sender);
    }
}

contract DaiJoinFab {
    function newDaiJoin(Vat vat, address dai) public returns (DaiJoin daiJoin) {
        daiJoin = new DaiJoin(vat, dai);
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

contract SpotFab {
    function newSpotter(Pit pit, bytes32 ilk) public returns (Spotter spotter) {
        spotter = new Spotter(pit, ilk);
        spotter.rely(msg.sender);
    }
}

contract ProxyFab {
    function newProxy() public returns (DSProxy proxy) {
        proxy = new DSProxy(new DSProxyCache());
        proxy.setOwner(msg.sender);
    }
}

contract DssDeploy is DSAuth {
    VatFab     public vatFab;
    PitFab     public pitFab;
    DripFab    public dripFab;
    VowFab     public vowFab;
    CatFab     public catFab;
    TokenFab   public tokenFab;
    GuardFab   public guardFab;
    DaiJoinFab public daiJoinFab;
    DaiMoveFab public daiMoveFab;
    FlapFab    public flapFab;
    FlopFab    public flopFab;
    FlipFab    public flipFab;
    SpotFab    public spotFab;
    ProxyFab   public proxyFab;

    Vat     public vat;
    Pit     public pit;
    Drip    public drip;
    Vow     public vow;
    Cat     public cat;
    DSToken public dai;
    DSGuard public guard;
    DaiJoin public daiJoin;
    DaiMove public daiMove;
    Flapper public flap;
    Flopper public flop;
    DSProxy public mom;

    mapping(bytes32 => Ilk) public ilks;

    uint8 public step = 0;

    uint256 constant ONE = 10 ** 27;

    struct Ilk {
        Flipper flip;
        address adapter;
        address mover;
        Spotter spotter;
    }

    constructor(
        VatFab vatFab_,
        PitFab pitFab_,
        DripFab dripFab_,
        VowFab vowFab_,
        CatFab catFab_,
        TokenFab tokenFab_,
        GuardFab guardFab_,
        DaiJoinFab daiJoinFab_,
        DaiMoveFab daiMoveFab_,
        FlapFab flapFab_,
        FlopFab flopFab_,
        FlipFab flipFab_,
        SpotFab spotFab_,
        ProxyFab proxyFab_
    ) public {
        vatFab = vatFab_;
        pitFab = pitFab_;
        dripFab = dripFab_;
        vowFab = vowFab_;
        catFab = catFab_;
        tokenFab = tokenFab_;
        guardFab = guardFab_;
        daiJoinFab = daiJoinFab_;
        daiMoveFab = daiMoveFab_;
        flapFab = flapFab_;
        flopFab = flopFab_;
        flipFab = flipFab_;
        spotFab = spotFab_;
        proxyFab = proxyFab_;
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
        daiJoin = daiJoinFab.newDaiJoin(vat, dai);
        guard = guardFab.newGuard();
        guard.permit(daiJoin, dai, bytes4(keccak256("mint(address,uint256)")));
        guard.permit(daiJoin, dai, bytes4(keccak256("burn(address,uint256)")));
        dai.setAuthority(guard);
        dai.setOwner(address(0));
        daiMove = daiMoveFab.newDaiMove(vat);

        // Internal auth
        vat.rely(daiJoin);
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
        vat.rely(vow);
        vat.rely(drip);
        vat.rely(flap);
        vat.rely(vow);
    }

    function deployLiquidation(address gov) public auth {
        require(vat != address(0), "Missing VAT deployment");
        require(pit != address(0), "Missing PIT deployment");
        require(vow != address(0), "Missing VOW deployment");

        // Deploy
        cat = catFab.newCat(vat);
        cat.file("vow", vow);
        cat.file("pit", pit);
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
        mom = proxyFab.newProxy();
        pit.rely(mom);
        cat.rely(mom);
        vow.rely(mom);
        drip.rely(mom);
        mom.setAuthority(authority);
        mom.setOwner(0);
        this.setAuthority(authority);
        this.setOwner(0);
        guard.setAuthority(authority);
        guard.setOwner(msg.sender);
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
        ilks[ilk].spotter = spotFab.newSpotter(pit, ilk);
        ilks[ilk].spotter.file(pip); // Set pip
        ilks[ilk].spotter.file(ONE); // Set mat

        // Internal references set up
        cat.file(ilk, "flip", ilks[ilk].flip);
        cat.file(ilk, "lump", uint(10000 ether)); // 10000 DAI per batch
        cat.file(ilk, "chop", ONE);
        vat.init(ilk);
        drip.init(ilk);
        drip.file("vow", bytes32(address(vow)));

        // Internal auth
        vat.rely(ilks[ilk].flip);
        vat.rely(adapter);
        vat.rely(mover);
        pit.rely(ilks[ilk].spotter);
        ilks[ilk].spotter.rely(mom);

        // Update spotter
        ilks[ilk].spotter.poke();
    }

    // developer backdoor
    function rely(address dev) public auth {
        vat.rely(dev);
        pit.rely(dev);
        cat.rely(dev);
        vow.rely(dev);
        flop.rely(dev);
        drip.rely(dev);
    }
}
