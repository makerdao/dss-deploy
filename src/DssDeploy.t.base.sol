pragma solidity >=0.5.0;

import {DSTest} from "ds-test/test.sol";
import {DSValue} from "ds-value/value.sol";
import {DSRoles} from "ds-roles/roles.sol";

import {GemJoin, ETHJoin} from "dss/join.sol";
import {GemMove} from 'dss/move.sol';

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

contract FakeUser {
    function doApprove(DSToken token, address guy) public {
        token.approve(guy);
    }

    function doDaiJoin(DaiJoin obj, bytes32 urn, uint wad) public {
        obj.join(urn, wad);
    }

    function doDaiExit(DaiJoin obj, bytes32 urn, address guy, uint wad) public {
        obj.exit(urn, guy, wad);
    }

    function doEthJoin(ETHJoin obj, bytes32 addr, uint wad) public {
        obj.join.value(wad)(addr);
    }

    function doFrob(Pit obj, bytes32 ilk, bytes32 urn, bytes32 gem, bytes32 dai, int dink, int dart) public {
        obj.frob(ilk, urn, gem, dai, dink, dart);
    }

    function doHope(DaiMove obj, address guy) public {
        obj.hope(guy);
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
    PitFab pitFab;
    DripFab dripFab;
    VowFab vowFab;
    CatFab catFab;
    TokenFab tokenFab;
    GuardFab guardFab;
    DaiJoinFab daiJoinFab;
    DaiMoveFab daiMoveFab;
    FlapFab flapFab;
    FlopFab flopFab;
    FlipFab flipFab;
    SpotFab spotFab;
    ProxyFab proxyFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipETH;
    DSValue pipDGX;

    DSRoles authority;
    DSGuard guard;

    ETHJoin ethJoin;
    GemJoin dgxJoin;

    Vat vat;
    Pit pit;
    Drip drip;
    Vow vow;
    Cat cat;
    Flapper flap;
    Flopper flop;
    DSToken dai;
    DaiJoin daiJoin;
    DaiMove daiMove;
    Spotter spotter;

    DSProxy mom;

    GemMove ethMove;
    Flipper ethFlip;

    DSToken dgx;
    GemMove dgxMove;
    Flipper dgxFlip;

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
        pitFab = new PitFab();
        dripFab = new DripFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        tokenFab = new TokenFab();
        guardFab = new GuardFab();
        daiJoinFab = new DaiJoinFab();
        daiMoveFab = new DaiMoveFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        proxyFab = new ProxyFab();

        flipFab = new FlipFab();
        spotFab = new SpotFab();

        uint startGas = gasleft();
        dssDeploy = new DssDeploy(
            vatFab,
            pitFab,
            DripFab(dripFab),
            vowFab,
            catFab,
            tokenFab,
            guardFab,
            daiJoinFab,
            daiMoveFab,
            FlapFab(flapFab),
            FlopFab(flopFab),
            FlipFab(flipFab),
            spotFab,
            proxyFab
        );
        uint endGas = gasleft();
        emit log_named_uint("Deploy DssDeploy", startGas - endGas);

        gov = new DSToken("GOV");
        gov.setAuthority(new DSGuard());
        pipETH = new DSValue();
        pipDGX = new DSValue();
        authority = new DSRoles();
        authority.setRootUser(address(this), true);

        user1 = new FakeUser();
        user2 = new FakeUser();
        address(user1).transfer(100 ether);
        address(user2).transfer(100 ether);

        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(0);
    }

    function file(address, bytes32, uint) external {
        mom.execute(address(momLib), msg.data);
    }

    function file(address, bytes32, bytes32, uint) external {
        mom.execute(address(momLib), msg.data);
    }

    function deploy() public {
        dssDeploy.deployVat();
        dssDeploy.deployPit();
        dssDeploy.deployDai();
        dssDeploy.deployTaxation(address(gov));
        dssDeploy.deployLiquidation(address(gov));
        dssDeploy.deployMom(authority);

        vat = dssDeploy.vat();
        pit = dssDeploy.pit();
        drip = dssDeploy.drip();
        vow = dssDeploy.vow();
        cat = dssDeploy.cat();
        flap = dssDeploy.flap();
        flop = dssDeploy.flop();
        dai = dssDeploy.dai();
        daiJoin = dssDeploy.daiJoin();
        daiMove = dssDeploy.daiMove();
        spotter = dssDeploy.spotter();
        guard = dssDeploy.guard();
        mom = dssDeploy.mom();

        ethJoin = new ETHJoin(address(vat), "ETH");
        ethMove = new GemMove(address(vat), "ETH");
        dssDeploy.deployCollateral("ETH", address(ethJoin), address(ethMove), address(pipETH));

        dgx = new DSToken("DGX");
        dgxJoin = new GemJoin(address(vat), "DGX", address(dgx));
        dgxMove = new GemMove(address(vat), "DGX");
        dssDeploy.deployCollateral("DGX", address(dgxJoin), address(dgxMove), address(pipDGX));

        // Set Params
        momLib = new MomLib();
        this.file(address(pit), bytes32("Line"), uint(10000 ether));
        this.file(address(pit), bytes32("ETH"), bytes32("line"), uint(10000 ether));
        this.file(address(pit), bytes32("DGX"), bytes32("line"), uint(10000 ether));

        pipETH.poke(bytes32(uint(300 * 10 ** 18))); // Price 300 DAI = 1 ETH (precision 18)
        pipDGX.poke(bytes32(uint(45 * 10 ** 18))); // Price 45 DAI = 1 DGX (precision 18)
        (ethFlip,,) = dssDeploy.ilks("ETH");
        (dgxFlip,,) = dssDeploy.ilks("DGX");
        this.file(address(spotter), "ETH", "mat", uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(spotter), "DGX", "mat", uint(1100000000 ether)); // Liquidation ratio 110%
        spotter.poke("ETH");
        spotter.poke("DGX");
        (uint spot, ) = pit.ilks("ETH");
        assertEq(spot, 300 * ONE * ONE / 1500000000 ether);
        (spot, ) = pit.ilks("DGX");
        assertEq(spot, 45 * ONE * ONE / 1100000000 ether);

        DSGuard(address(gov.authority())).permit(address(flop), address(gov), bytes4(keccak256("mint(address,uint256)")));

        gov.mint(100 ether);
    }

    function() external payable {
    }
}
