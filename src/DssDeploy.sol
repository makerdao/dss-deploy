/// DssDeploy.sol

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.0;

import {DSToken} from "ds-token/token.sol";
import {DSAuth, DSAuthority} from "ds-auth/auth.sol";
import {DSGuard} from "ds-guard/guard.sol";
import {DSProxy, DSProxyCache} from "ds-proxy/proxy.sol";

import {Vat} from "dss/vat.sol";
import {Jug} from "dss/jug.sol";
import {Vow} from "dss/vow.sol";
import {Cat} from "dss/cat.sol";
import {DaiJoin} from "dss/join.sol";
import {DaiMove} from "dss/move.sol";
import {Flapper} from "dss/flap.sol";
import {Flopper} from "dss/flop.sol";
import {Flipper} from "dss/flip.sol";

import {Pot} from "dsr/dsr.sol";

import {Spotter} from "./poke.sol";

contract VatFab {
    function newVat() public returns (Vat vat) {
        vat = new Vat();
        vat.rely(msg.sender);
        vat.deny(address(this));
    }
}

contract JugFab {
    function newJug(Vat vat) public returns (Jug jug) {
        jug = new Jug(address(vat));
        jug.rely(msg.sender);
        jug.deny(address(this));
    }
}

contract VowFab {
    function newVow() public returns (Vow vow) {
        vow = new Vow();
        vow.rely(msg.sender);
        vow.deny(address(this));
    }
}

contract CatFab {
    function newCat(Vat vat) public returns (Cat cat) {
        cat = new Cat(address(vat));
        cat.rely(msg.sender);
        cat.deny(address(this));
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
        daiJoin = new DaiJoin(address(vat), address(dai));
    }
}

contract DaiMoveFab {
    function newDaiMove(Vat vat) public returns (DaiMove daiMove) {
        daiMove = new DaiMove(address(vat));
    }
}

contract FlapFab {
    function newFlap(address dai, address gov) public returns (Flapper flap) {
        flap = new Flapper(dai, gov);
    }
}

contract FlopFab {
    function newFlop(address dai, address gov) public returns (Flopper flop) {
        flop = new Flopper(address(dai), address(gov));
        flop.rely(msg.sender);
        flop.deny(address(this));
    }
}

contract FlipFab {
    function newFlip(address dai, address gem) public returns (Flipper flop) {
        flop = new Flipper(address(dai), address(gem));
    }
}

contract SpotFab {
    function newSpotter(Vat vat) public returns (Spotter spotter) {
        spotter = new Spotter(address(vat));
        spotter.rely(msg.sender);
        spotter.deny(address(this));
    }
}

contract PotFab {
    function newPot(Vat vat) public returns (Pot pot) {
        pot = new Pot(address(vat));
        pot.rely(msg.sender);
        pot.deny(address(this));
    }
}

contract ProxyFab {
    function newProxy() public returns (DSProxy proxy) {
        proxy = new DSProxy(address(new DSProxyCache()));
        proxy.setOwner(msg.sender);
    }
}

contract DssDeploy is DSAuth {
    VatFab     public vatFab;
    JugFab     public jugFab;
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
    PotFab     public potFab;
    ProxyFab   public proxyFab;

    Vat     public vat;
    Jug     public jug;
    Vow     public vow;
    Cat     public cat;
    DSToken public dai;
    DSGuard public guard;
    DaiJoin public daiJoin;
    DaiMove public daiMove;
    Flapper public flap;
    Flopper public flop;
    Spotter public spotter;
    Pot     public pot;
    DSProxy public mom;

    mapping(bytes32 => Ilk) public ilks;

    uint8 public step = 0;

    uint256 constant ONE = 10 ** 27;

    struct Ilk {
        Flipper flip;
        address adapter;
        address mover;
    }

    constructor(
        VatFab vatFab_,
        JugFab jugFab_,
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
        jugFab = jugFab_;
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

    function addExtraFabs(PotFab potFab_) public auth {
        potFab = potFab_;
    }

    function deployVat() public auth {
        require(address(potFab) != address(0), "addExtraFabs not executed");
        require(address(vat) == address(0), "VAT already deployed");
        vat = vatFab.newVat();
        spotter = spotFab.newSpotter(vat);

        // Internal auth
        vat.rely(address(spotter));
    }

    function deployDai() public auth {
        require(address(vat) != address(0), "Missing VAT deployment");

        // Deploy
        dai     = tokenFab.newToken("DAI");
        daiJoin = daiJoinFab.newDaiJoin(vat, address(dai));
        guard = guardFab.newGuard();
        guard.permit(address(daiJoin), address(dai), bytes4(keccak256("mint(address,uint256)")));
        guard.permit(address(daiJoin), address(dai), bytes4(keccak256("burn(address,uint256)")));
        dai.setAuthority(guard);
        dai.setOwner(address(0));
        daiMove = daiMoveFab.newDaiMove(vat);

        // Internal auth
        vat.rely(address(daiJoin));
        vat.rely(address(daiMove));
    }

    function deployTaxation(address gov) public auth {
        require(gov != address(0), "Missing GOV address");
        require(address(vat) != address(0), "Missing VAT deployment");

        // Deploy
        vow = vowFab.newVow();
        jug = jugFab.newJug(vat);
        pot = potFab.newPot(vat);
        flap = flapFab.newFlap(address(daiMove), gov);

        // Internal references set up
        vow.file("vat", address(vat));
        vow.file("flap", address(flap));
        jug.file("vow", bytes32(bytes20(address(vow))));
        pot.file("vow", bytes32(bytes20(address(vow))));

        // Internal auth
        vat.rely(address(vow));
        vat.rely(address(jug));
        vat.rely(address(pot));
    }

    function deployLiquidation(address gov) public auth {
        require(address(vat) != address(0), "Missing VAT deployment");
        require(address(vow) != address(0), "Missing VOW deployment");

        // Deploy
        cat = catFab.newCat(vat);
        cat.file("vow", address(vow));
        flop = flopFab.newFlop(address(daiMove), gov);

        // Internal references set up
        vow.file("flop", address(flop));

        // Internal auth
        vat.rely(address(cat));
        vow.rely(address(cat));
        flop.rely(address(vow));
    }

    function deployMom(DSAuthority authority) public auth {
        require(address(vow) != address(0), "Missing VOW deployment");
        require(address(jug) != address(0), "Missing JUG deployment");
        require(address(cat) != address(0), "Missing CAT deployment");

        // Auth
        mom = proxyFab.newProxy();
        vat.rely(address(mom));
        cat.rely(address(mom));
        vow.rely(address(mom));
        jug.rely(address(mom));
        pot.rely(address(mom));
        spotter.rely(address(mom));
        mom.setAuthority(authority);
        mom.setOwner(address(0));
        this.setAuthority(authority);
        this.setOwner(address(0));
        guard.setAuthority(authority);
        guard.setOwner(msg.sender);
    }

    function deployCollateral(bytes32 ilk, address adapter, address mover, address pip) public auth {
        require(ilk != bytes32(""), "Missing ilk name");
        require(adapter != address(0), "Missing adapter address");
        require(mover   != address(0), "Missing mover address");
        require(pip != address(0), "Missing PIP address");
        require(address(vat) != address(0), "Missing VAT deployment");
        require(address(cat) != address(0), "Missing CAT deployment");

        // Deploy
        ilks[ilk].flip = flipFab.newFlip(address(daiMove), mover);
        ilks[ilk].adapter = adapter;
        ilks[ilk].mover = mover;
        Spotter(spotter).file(ilk, address(pip)); // Set pip
        Spotter(spotter).file(ilk, "mat", ONE); // Set mat

        // Internal references set up
        cat.file(ilk, "flip", address(ilks[ilk].flip));
        cat.file(ilk, "lump", uint(10000 ether)); // 10000 DAI per batch
        cat.file(ilk, "chop", ONE);
        vat.init(ilk);
        jug.init(ilk);

        // Internal auth
        vat.rely(adapter);
        vat.rely(mover);

        // Update spotter
        spotter.poke(ilk);
    }

    // developer backdoor
    function rely(address dev) public auth {
        vat.rely(dev);
        cat.rely(dev);
        vow.rely(dev);
        flop.rely(dev);
        jug.rely(dev);
        pot.rely(dev);
        spotter.rely(dev);
    }
}
