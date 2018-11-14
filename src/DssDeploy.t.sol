pragma solidity ^0.4.24;

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

    function doDaiExit(DaiJoin obj, address guy, uint wad) public {
        obj.exit(guy, wad);
    }

    function doEthJoin(ETHJoin obj, bytes32 addr, uint wad) public {
        obj.join.value(wad)(addr);
    }

    function doFrob(Pit obj, bytes32 ilk, int dink, int dart) public {
        obj.frob(ilk, dink, dart);
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

    function() public payable {
    }
}

contract DssDeployTest is DSTest {
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

    DSProxy mom;

    GemMove ethMove;
    Spotter ethPrice;
    Flipper ethFlip;

    DSToken dgx;
    GemMove dgxMove;
    Spotter dgxPrice;
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
        authority.setRootUser(this, true);

        user1 = new FakeUser();
        user2 = new FakeUser();
        address(user1).transfer(100 ether);
        address(user2).transfer(100 ether);

        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(0);
    }

    function file(address, uint) external {
        mom.execute(momLib, msg.data);
    }

    function file(address, bytes32, uint) external {
        mom.execute(momLib, msg.data);
    }

    function file(address, bytes32, bytes32, uint) external {
        mom.execute(momLib, msg.data);
    }

    function deploy() public {
        dssDeploy.deployVat();
        dssDeploy.deployPit();
        dssDeploy.deployDai();
        dssDeploy.deployTaxation(gov);
        dssDeploy.deployLiquidation(gov);
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
        guard = dssDeploy.guard();
        mom = dssDeploy.mom();

        ethJoin = new ETHJoin(vat, "ETH");
        ethMove = new GemMove(vat, "ETH");
        dssDeploy.deployCollateral("ETH", ethJoin, ethMove, pipETH);

        dgx = new DSToken("DGX");
        dgxJoin = new GemJoin(vat, "DGX", dgx);
        dgxMove = new GemMove(vat, "DGX");
        dssDeploy.deployCollateral("DGX", dgxJoin, dgxMove, pipDGX);

        // Set Params
        momLib = new MomLib();
        this.file(address(pit), bytes32("Line"), uint(10000 ether));
        this.file(address(pit), bytes32("ETH"), bytes32("line"), uint(10000 ether));
        this.file(address(pit), bytes32("DGX"), bytes32("line"), uint(10000 ether));

        pipETH.poke(300 * 10 ** 18); // Price 300 DAI = 1 ETH (precision 18)
        pipDGX.poke(45 * 10 ** 18); // Price 45 DAI = 1 DGX (precision 18)
        (ethFlip,,, ethPrice) = dssDeploy.ilks("ETH");
        (dgxFlip,,, dgxPrice) = dssDeploy.ilks("DGX");
        this.file(address(ethPrice), uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(dgxPrice), uint(1100000000 ether)); // Liquidation ratio 110%
        ethPrice.poke();
        dgxPrice.poke();
        (uint spot, ) = pit.ilks("ETH");
        assertEq(spot, 300 * ONE * ONE / 1500000000 ether);
        (spot, ) = pit.ilks("DGX");
        assertEq(spot, 45 * ONE * ONE / 1100000000 ether);

        DSGuard(gov.authority()).permit(flop, gov, bytes4(keccak256("mint(address,uint256)")));

        gov.mint(100 ether);
    }

    function testDeploy() public {
        deploy();
    }

    function testFailDeploy() public {
        dssDeploy.deployPit();
    }

    function testFailDeploy2() public {
        dssDeploy.deployVat();
        dssDeploy.deployTaxation(gov);
    }

    function testFailDeploy3() public {
        dssDeploy.deployVat();
        dssDeploy.deployPit();
        dssDeploy.deployDai();
        dssDeploy.deployLiquidation(gov);
    }

    function testFailDeploy4() public {
        dssDeploy.deployVat();
        dssDeploy.deployPit();
        dssDeploy.deployDai();
        dssDeploy.deployTaxation(gov);
        dssDeploy.deployMom(authority);
    }

    function testJoinETH() public {
        deploy();
        assertEq(vat.gem("ETH", bytes32(address(this))), 0);
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        assertEq(vat.gem("ETH", bytes32(address(this))), mul(ONE, 1 ether));
    }

    function testJoinGem() public {
        deploy();
        dgx.mint(1 ether);
        assertEq(dgx.balanceOf(this), 1 ether);
        assertEq(vat.gem("DGX", bytes32(address(this))), 0);
        dgx.approve(dgxJoin, 1 ether);
        dgxJoin.join(bytes32(address(this)), 1 ether);
        assertEq(dgx.balanceOf(this), 0);
        assertEq(vat.gem("DGX", bytes32(address(this))), mul(ONE, 1 ether));
    }

    function testExitETH() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        ethJoin.exit(address(this), 1 ether);
        assertEq(vat.gem("ETH", bytes32(address(this))), 0);
    }

    function testExitGem() public {
        deploy();
        dgx.mint(1 ether);
        dgx.approve(dgxJoin, 1 ether);
        dgxJoin.join(bytes32(address(this)), 1 ether);
        dgxJoin.exit(address(this), 1 ether);
        assertEq(dgx.balanceOf(this), 1 ether);
        assertEq(vat.gem("DGX", bytes32(address(this))), 0);
    }

    function testDrawDai() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        ethJoin.join.value(1 ether)(bytes32(address(this)));

        pit.frob("ETH", 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", bytes32(address(this))), mul(ONE, 0.5 ether));
        assertEq(vat.dai(bytes32(address(this))), mul(ONE, 60 ether));

        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        assertEq(vat.dai(bytes32(address(this))), 0);
    }

    function testDrawDaiGem() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        dgx.mint(1 ether);
        dgx.approve(dgxJoin, 1 ether);
        dgxJoin.join(bytes32(address(this)), 1 ether);

        pit.frob("DGX", 0.5 ether, 20 ether);

        daiJoin.exit(address(this), 20 ether);
        assertEq(dai.balanceOf(address(this)), 20 ether);
    }

    function testDrawDaiLimit() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 DAI max
    }

    function testDrawDaiGemLimit() public {
        deploy();
        dgx.mint(1 ether);
        dgx.approve(dgxJoin, 1 ether);
        dgxJoin.join(bytes32(address(this)), 1 ether);
        pit.frob("DGX", 0.5 ether, 20.454545454545454545 ether); // 0.5 * 45 / 1.1 = 20.454545454545454545 DAI max
    }

    function testFailDrawDaiLimit() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether + 1);
    }

    function testFailDrawDaiGemLimit() public {
        deploy();
        dgx.mint(1 ether);
        dgx.approve(dgxJoin, 1 ether);
        dgxJoin.join(bytes32(address(this)), 1 ether);
        pit.frob("DGX", 0.5 ether, 20.454545454545454545 ether + 1);
    }

    function testPaybackDai() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 60 ether);
        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        dai.approve(daiJoin, uint(-1));
        daiJoin.join(bytes32(address(this)), 60 ether);
        assertEq(dai.balanceOf(address(this)), 0);

        assertEq(vat.dai(bytes32(address(this))), mul(ONE, 60 ether));
        pit.frob("ETH", 0 ether, -60 ether);
        assertEq(vat.dai(bytes32(address(this))), 0);
    }

    function testFailBite() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether); // Maximun DAI

        cat.bite("ETH", bytes32(address(this)));
    }

    function testBite() public {
        deploy();
        ethJoin.join.value(0.5 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether); // Maximun DAI generated

        pipETH.poke(300 * 10 ** 18 - 1); // Decrease price in 1 wei
        ethPrice.poke();

        (uint ink, uint art) = vat.urns("ETH", bytes32(address(this)));
        assertEq(ink, 0.5 ether);
        assertEq(art, 100 ether);
        cat.bite("ETH", bytes32(address(this)));
        (ink, art) = vat.urns("ETH", bytes32(address(this)));
        assertEq(ink, 0);
        assertEq(art, 0);
    }

    function testFlip() public {
        deploy();
        ethJoin.join.value(0.5 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether); // Maximun DAI generated
        pipETH.poke(300 * 10 ** 18 - 1); // Decrease price in 1 wei
        ethPrice.poke();
        uint nflip = cat.bite("ETH", bytes32(address(this)));
        assertEq(vat.gem("ETH", bytes32(address(ethFlip))), 0);
        uint batchId = cat.flip(nflip, 100 ether);
        assertEq(vat.gem("ETH", bytes32(address(ethFlip))), mul(0.5 ether, ONE));
        address(user1).transfer(10 ether);
        user1.doEthJoin(ethJoin, bytes32(address(user1)), 10 ether);
        user1.doFrob(pit, "ETH", 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(ethJoin, bytes32(address(user2)), 10 ether);
        user2.doFrob(pit, "ETH", 10 ether, 1000 ether);

        user1.doHope(daiMove, ethFlip);
        user2.doHope(daiMove, ethFlip);

        user1.doTend(ethFlip, batchId, 0.5 ether, 50 ether);
        user2.doTend(ethFlip, batchId, 0.5 ether, 70 ether);
        user1.doTend(ethFlip, batchId, 0.5 ether, 90 ether);
        user2.doTend(ethFlip, batchId, 0.5 ether, 100 ether);

        user1.doDent(ethFlip, batchId, 0.4 ether, 100 ether);
        user2.doDent(ethFlip, batchId, 0.35 ether, 100 ether);
        hevm.warp(ethFlip.ttl() - 1);
        user1.doDent(ethFlip, batchId, 0.3 ether, 100 ether);
        hevm.warp(now + ethFlip.ttl() + 1);
        user1.doDeal(ethFlip, batchId);
    }

    function testFlop() public {
        deploy();
        ethJoin.join.value(0.5 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether); // Maximun DAI generated
        pipETH.poke(300 * 10 ** 18 - 1); // Decrease price in 1 wei
        ethPrice.poke();
        uint48 eraBite = uint48(now);
        uint nflip = cat.bite("ETH", bytes32(address(this)));
        uint batchId = cat.flip(nflip, 100 ether);
        address(user1).transfer(10 ether);
        user1.doEthJoin(ethJoin, bytes32(address(user1)), 10 ether);
        user1.doFrob(pit, "ETH", 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(ethJoin, bytes32(address(user2)), 10 ether);
        user2.doFrob(pit, "ETH", 10 ether, 1000 ether);

        user1.doHope(daiMove, ethFlip);
        user2.doHope(daiMove, ethFlip);

        user1.doTend(ethFlip, batchId, 0.5 ether, 50 ether);
        user2.doTend(ethFlip, batchId, 0.5 ether, 70 ether);
        user1.doTend(ethFlip, batchId, 0.5 ether, 90 ether);

        hevm.warp(now + ethFlip.ttl() + 1);
        user1.doDeal(ethFlip, batchId);

        vow.flog(eraBite);
        vow.heal(90 ether);
        this.file(address(vow), bytes32("sump"), uint(10 ether));
        batchId = vow.flop();

        (uint bid,,,,,) = flop.bids(batchId);
        assertEq(bid, 10 ether);
        user1.doHope(daiMove, flop);
        user2.doHope(daiMove, flop);
        user1.doDent(flop, batchId, 0.3 ether, 10 ether);
        hevm.warp(now + flop.ttl() - 1);
        user2.doDent(flop, batchId, 0.1 ether, 10 ether);
        user1.doDent(flop, batchId, 0.08 ether, 10 ether);
        hevm.warp(now + flop.ttl() + 1);
        uint prevGovSupply = gov.totalSupply();
        user1.doDeal(flop, batchId);
        assertEq(gov.totalSupply(), prevGovSupply + 0.08 ether);
        vow.kiss(10 ether);
        assertEq(vow.Joy(), 0);
        assertEq(vow.Woe(), 0);
        assertEq(vow.Awe(), 0);
    }

    function testFlap() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        ethJoin.join.value(0.5 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vow.Joy(), 0);
        drip.drip("ETH");
        assertEq(vow.Joy(), 10 * 0.05 * 10 ** 18);
        this.file(address(vow), bytes32("bump"), uint(0.05 ether));
        uint batchId = vow.flap();

        (,uint lot,,,,) = flap.bids(batchId);
        assertEq(lot, 0.05 ether);
        user1.doApprove(gov, flap);
        user2.doApprove(gov, flap);
        gov.transfer(user1, 1 ether);
        gov.transfer(user2, 1 ether);

        assertEq(dai.balanceOf(user1), 0);
        assertEq(gov.balanceOf(address(0)), 0);

        user1.doTend(flap, batchId, 0.05 ether, 0.001 ether);
        user2.doTend(flap, batchId, 0.05 ether, 0.0015 ether);
        user1.doTend(flap, batchId, 0.05 ether, 0.0016 ether);

        assertEq(gov.balanceOf(user1), 1 ether - 0.0016 ether);
        assertEq(gov.balanceOf(user2), 1 ether);
        hevm.warp(now + flap.ttl() + 1);
        user1.doDeal(flap, batchId);
        assertEq(gov.balanceOf(address(0)), 0.0016 ether);
        user1.doDaiExit(daiJoin, user1, 0.05 ether);
        assertEq(dai.balanceOf(user1), 0.05 ether);
    }

    function testAuth() public {
        deploy();

        // vat
        assertEq(vat.wards(dssDeploy), 1);

        assertEq(vat.wards(ethFlip), 1);
        assertEq(vat.wards(ethJoin), 1);
        assertEq(vat.wards(ethMove), 1);

        assertEq(vat.wards(dgxFlip), 1);
        assertEq(vat.wards(dgxJoin), 1);
        assertEq(vat.wards(dgxMove), 1);

        assertEq(vat.wards(daiJoin), 1);
        assertEq(vat.wards(daiMove), 1);

        assertEq(vat.wards(flap), 1);
        assertEq(vat.wards(flop), 1);
        assertEq(vat.wards(vow), 1);
        assertEq(vat.wards(cat), 1);
        assertEq(vat.wards(pit), 1);
        assertEq(vat.wards(drip), 1);

        // dai
        assertEq(dai.authority(), guard);
        assertTrue(guard.canCall(address(daiJoin), address(dai), bytes4(keccak256("mint(address,uint256)"))));
        assertTrue(guard.canCall(address(daiJoin), address(dai), bytes4(keccak256("burn(address,uint256)"))));

        // flop
        assertEq(flop.wards(dssDeploy), 1);
        assertEq(flop.wards(vow), 1);

        // vow
        assertEq(vow.wards(dssDeploy), 1);
        assertEq(vow.wards(mom), 1);
        assertEq(vow.wards(cat), 1);

        // cat
        assertEq(cat.wards(dssDeploy), 1);
        assertEq(cat.wards(mom), 1);

        // pit
        assertEq(pit.wards(dssDeploy), 1);
        assertEq(pit.wards(mom), 1);
        assertEq(pit.wards(ethPrice), 1);
        assertEq(pit.wards(dgxPrice), 1);

        // spotters
        assertEq(ethPrice.wards(dssDeploy), 1);
        assertEq(ethPrice.wards(mom), 1);

        assertEq(dgxPrice.wards(dssDeploy), 1);
        assertEq(dgxPrice.wards(mom), 1);

        // drip
        assertEq(drip.wards(dssDeploy), 1);
        assertEq(drip.wards(mom), 1);

        // mom
        assertEq(mom.authority(), authority);
        assertEq(mom.owner(), address(0));

        // dssDeploy
        assertEq(dssDeploy.authority(), authority);
        assertEq(dssDeploy.owner(), address(0));

        // root
        assertTrue(authority.isUserRoot(this));

        // guard
        assertEq(guard.authority(), authority);
        assertEq(guard.owner(), this);
    }

    function() public payable {
    }
}
