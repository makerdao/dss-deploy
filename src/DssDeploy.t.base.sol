pragma solidity >=0.5.0;

import {DSTest} from "ds-test/test.sol";
import {DSValue} from "ds-value/value.sol";
import {DSRoles} from "ds-roles/roles.sol";

import {GemJoin} from "dss/join.sol";
import {WETH9_} from "ds-weth/weth9.sol";

import "./DssDeploy.sol";

import {MomLib} from "./momLib.sol";

contract Hevm {
    function warp(uint256) public;
}

contract AuctionLike {
    function tend(uint, uint, uint) public;
    function dent(uint, uint, uint) public;
    function deal(uint) public;
}

contract HopeLike {
    function hope(address guy) public;
}

contract FakeUser {
    function doApprove(address token, address guy) public {
        DSToken(token).approve(guy);
    }

    function doDaiJoin(address obj, address urn, uint wad) public {
        DaiJoin(obj).join(urn, wad);
    }

    function doDaiExit(address obj, address guy, uint wad) public {
        DaiJoin(obj).exit(guy, wad);
    }

    function doEthJoin(address payable obj, address gem, address urn, uint wad) public {
        WETH9_(obj).deposit.value(wad)();
        WETH9_(obj).approve(address(gem), uint(-1));
        GemJoin(gem).join(urn, wad);
    }

    function doFrob(address obj, bytes32 ilk, address urn, address gem, address dai, int dink, int dart) public {
        Vat(obj).frob(ilk, urn, gem, dai, dink, dart);
    }

    function doFork(address obj, bytes32 ilk, address src, address dst, int dink, int dart) public {
        Vat(obj).fork(ilk, src, dst, dink, dart);
    }

    function doHope(address obj, address guy) public {
        HopeLike(obj).hope(guy);
    }

    function doTend(address obj, uint id, uint lot, uint bid) public {
        AuctionLike(obj).tend(id, lot, bid);
    }

    function doDent(address obj, uint id, uint lot, uint bid) public {
        AuctionLike(obj).dent(id, lot, bid);
    }

    function doDeal(address obj, uint id) public {
        AuctionLike(obj).deal(id);
    }

    function() external payable {
    }
}

contract DssDeployTestBase is DSTest {
    Hevm hevm;

    VatFab vatFab;
    JugFab jugFab;
    VowFab vowFab;
    CatFab catFab;
    TokenFab tokenFab;
    GuardFab guardFab;
    DaiJoinFab daiJoinFab;
    FlapFab flapFab;
    FlopFab flopFab;
    FlipFab flipFab;
    SpotFab spotFab;
    PotFab potFab;
    ProxyFab proxyFab;
    PauseFab pauseFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipETH;
    DSValue pipCOL;

    DSRoles authority;
    DSGuard guard;
    DSPause pause;

    WETH9_ weth;
    GemJoin ethJoin;
    GemJoin colJoin;

    Vat vat;
    Jug jug;
    Vow vow;
    Cat cat;
    Flapper flap;
    Flopper flop;
    DSToken dai;
    DaiJoin daiJoin;
    Spotter spotter;
    Pot pot;

    DSProxy mom;

    Flipper ethFlip;

    DSToken col;
    Flipper colFlip;

    FakeUser user1;
    FakeUser user2;

    MomLib momLib;

    // --- Math ---
    uint256 constant ONE = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function setUp() public {
        vatFab = new VatFab();
        jugFab = new JugFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        tokenFab = new TokenFab();
        guardFab = new GuardFab();
        daiJoinFab = new DaiJoinFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        flipFab = new FlipFab();
        spotFab = new SpotFab();
        proxyFab = new ProxyFab();
        potFab = new PotFab();
        pauseFab = new PauseFab();

        dssDeploy = new DssDeploy(
            vatFab,
            jugFab,
            vowFab,
            catFab,
            tokenFab,
            guardFab,
            daiJoinFab,
            flapFab,
            flopFab,
            flipFab,
            spotFab,
            proxyFab,
            potFab,
            pauseFab
        );

        gov = new DSToken("GOV");
        gov.setAuthority(new DSGuard());
        pipETH = new DSValue();
        pipCOL = new DSValue();
        authority = new DSRoles();
        authority.setRootUser(address(this), true);

        user1 = new FakeUser();
        user2 = new FakeUser();
        address(user1).transfer(100 ether);
        address(user2).transfer(100 ether);

        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(0);
    }

    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function file(address, bytes32, uint) external {
        mom.execute(address(momLib), msg.data);
    }

    function file(address, bytes32, bytes32, uint) external {
        mom.execute(address(momLib), msg.data);
    }

    function deploy() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai();
        dssDeploy.deployTaxation(address(gov));
        dssDeploy.deployLiquidation(address(gov));
        dssDeploy.deployMom(authority);
        dssDeploy.deployPause(0, authority);

        vat = dssDeploy.vat();
        jug = dssDeploy.jug();
        vow = dssDeploy.vow();
        cat = dssDeploy.cat();
        flap = dssDeploy.flap();
        flop = dssDeploy.flop();
        dai = dssDeploy.dai();
        daiJoin = dssDeploy.daiJoin();
        spotter = dssDeploy.spotter();
        pot = dssDeploy.pot();
        guard = dssDeploy.guard();
        mom = dssDeploy.mom();
        pause = dssDeploy.pause();
        authority.setRootUser(address(pause), true);

        weth = new WETH9_();
        ethJoin = new GemJoin(address(vat), "ETH", address(weth));
        dssDeploy.deployCollateral("ETH", address(ethJoin), address(pipETH));

        col = new DSToken("COL");
        colJoin = new GemJoin(address(vat), "COL", address(col));
        dssDeploy.deployCollateral("COL", address(colJoin), address(pipCOL));

        // Set Params
        momLib = new MomLib();
        this.file(address(vat), bytes32("Line"), uint(10000 * 10 ** 45));
        this.file(address(vat), bytes32("ETH"), bytes32("line"), uint(10000 * 10 ** 45));
        this.file(address(vat), bytes32("COL"), bytes32("line"), uint(10000 * 10 ** 45));

        pipETH.poke(bytes32(uint(300 * 10 ** 18))); // Price 300 DAI = 1 ETH (precision 18)
        pipCOL.poke(bytes32(uint(45 * 10 ** 18))); // Price 45 DAI = 1 COL (precision 18)
        (ethFlip,) = dssDeploy.ilks("ETH");
        (colFlip,) = dssDeploy.ilks("COL");
        this.file(address(spotter), "ETH", "mat", uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(spotter), "COL", "mat", uint(1100000000 ether)); // Liquidation ratio 110%
        spotter.poke("ETH");
        spotter.poke("COL");
        (,,uint spot,,) = vat.ilks("ETH");
        assertEq(spot, 300 * ONE * ONE / 1500000000 ether);
        (,, spot,,) = vat.ilks("COL");
        assertEq(spot, 45 * ONE * ONE / 1100000000 ether);

        DSGuard(address(gov.authority())).permit(address(flop), address(gov), bytes4(keccak256("mint(address,uint256)")));

        gov.mint(100 ether);
    }

    function() external payable {
    }
}
