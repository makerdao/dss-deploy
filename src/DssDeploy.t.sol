pragma solidity ^0.5.12;

import "./DssDeploy.t.base.sol";

import "./join.sol";

import "./tokens.sol";

contract DssDeployTest is DssDeployTestBase {
    function testDeploy() public {
        deploy();
    }

    function testFailMissingVat() public {
        dssDeploy.deployTaxation();
    }

    function testFailMissingTaxation() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai(99);
        dssDeploy.deployAuctions(address(gov));
    }

    function testFailMissingAuctions() public {
        dssDeploy.deployVat();
        dssDeploy.deployTaxation();
        dssDeploy.deployDai(99);
        dssDeploy.deployLiquidator();
    }

    function testFailMissingLiquidator() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployShutdown(address(gov), address(0x0), 10);
    }

    function testFailMissingEnd() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployPause(0, authority);
    }

    function testJoinETH() public {
        deploy();
        assertEq(vat.gem("ETH", address(this)), 0);
        weth.deposit.value(1 ether)();
        assertEq(weth.balanceOf(address(this)), 1 ether);
        weth.approve(address(ethJoin), 1 ether);
        ethJoin.join(address(this), 1 ether);
        assertEq(weth.balanceOf(address(this)), 0);
        assertEq(vat.gem("ETH", address(this)), 1 ether);
    }

    function testJoinGem() public {
        deploy();
        col.mint(1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", address(this)), 0);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 0);
        assertEq(vat.gem("COL", address(this)), 1 ether);
    }

    function testExitETH() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        ethJoin.exit(address(this), 1 ether);
        assertEq(vat.gem("ETH", address(this)), 0);
    }

    function testExitGem() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        colJoin.exit(address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", address(this)), 0);
    }

    function testFrobDrawDai() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", address(this)), 0.5 ether);
        assertEq(vat.dai(address(this)), mul(ONE, 60 ether));

        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        assertEq(vat.dai(address(this)), 0);
    }

    function testFrobDrawDaiGem() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);

        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20 ether);

        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 20 ether);
        assertEq(dai.balanceOf(address(this)), 20 ether);
    }

    function testFrobDrawDaiLimit() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 DAI max
    }

    function testFrobDrawDaiGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20.454545454545454545 ether); // 0.5 * 45 / 1.1 = 20.454545454545454545 DAI max
    }

    function testFailFrobDrawDaiLimit() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 100 ether + 1);
    }

    function testFailFrobDrawDaiGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20.454545454545454545 ether + 1);
    }

    function testFrobPaybackDai() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        dai.approve(address(daiJoin), uint(-1));
        daiJoin.join(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 0);

        assertEq(vat.dai(address(this)), mul(ONE, 60 ether));
        vat.frob("ETH", address(this), address(this), address(this), 0 ether, -60 ether);
        assertEq(vat.dai(address(this)), 0);
    }

    function testFrobFromAnotherUser() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.hope(address(user1));
        user1.doFrob(address(vat), "ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailFrobDust() public {
        deploy();
        weth.deposit.value(100 ether)(); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 100 ether);

        this.file(address(vat), "ETH", "dust", mul(ONE, 20 ether));
        vat.frob("ETH", address(this), address(this), address(this), 100 ether, 19 ether);
    }

    function testFailFrobFromAnotherUser() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        user1.doFrob(address(vat), "ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailBite() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 100 ether); // Maximun DAI

        cat.bite("ETH", address(this));
    }

    function testBite() public {
        deploy();
        this.file(address(cat), "ETH", "lump", 1 ether); // 1 unit of collateral per batch
        this.file(address(cat), "ETH", "chop", ONE);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun DAI generated

        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");

        (uint ink, uint art) = vat.urns("ETH", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 200 ether);
        cat.bite("ETH", address(this));
        (ink, art) = vat.urns("ETH", address(this));
        assertEq(ink, 0);
        assertEq(art, 0);
    }

    function testBitePartial() public {
        deploy();
        this.file(address(cat), "ETH", "lump", 1 ether); // 1 unit of collateral per batch
        this.file(address(cat), "ETH", "chop", ONE);
        weth.deposit.value(10 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 10 ether);
        vat.frob("ETH", address(this), address(this), address(this), 10 ether, 2000 ether); // Maximun DAI generated

        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");

        (uint ink, uint art) = vat.urns("ETH", address(this));
        assertEq(ink, 10 ether);
        assertEq(art, 2000 ether);
        cat.bite("ETH", address(this));
        (ink, art) = vat.urns("ETH", address(this));
        assertEq(ink, 9 ether);
        assertEq(art, 1800 ether);
    }

    function testFlip() public {
        deploy();
        this.file(address(cat), "ETH", "lump", 1 ether); // 1 unit of collateral per batch
        this.file(address(cat), "ETH", "chop", ONE);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        assertEq(vat.gem("ETH", address(ethFlip)), 0);
        uint batchId = cat.bite("ETH", address(this));
        assertEq(vat.gem("ETH", address(ethFlip)), 1 ether);
        address(user1).transfer(10 ether);
        user1.doEthJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(address(weth), address(ethJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "ETH", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(ethFlip));
        user2.doHope(address(vat), address(ethFlip));

        user1.doTend(address(ethFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(ethFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(ethFlip), batchId, 1 ether, rad(180 ether));
        user2.doTend(address(ethFlip), batchId, 1 ether, rad(200 ether));

        user1.doDent(address(ethFlip), batchId, 0.8 ether, rad(200 ether));
        user2.doDent(address(ethFlip), batchId, 0.7 ether, rad(200 ether));
        hevm.warp(ethFlip.ttl() - 1);
        user1.doDent(address(ethFlip), batchId, 0.6 ether, rad(200 ether));
        hevm.warp(now + ethFlip.ttl() + 1);
        user1.doDeal(address(ethFlip), batchId);
    }

    function _flop() internal returns (uint batchId) {
        this.file(address(cat), "ETH", "lump", 1 ether); // 1 unit of collateral per batch
        this.file(address(cat), "ETH", "chop", ONE);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        uint48 eraBite = uint48(now);
        batchId = cat.bite("ETH", address(this));
        address(user1).transfer(10 ether);
        user1.doEthJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(address(weth), address(ethJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "ETH", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(ethFlip));
        user2.doHope(address(vat), address(ethFlip));

        user1.doTend(address(ethFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(ethFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(ethFlip), batchId, 1 ether, rad(180 ether));

        hevm.warp(now + ethFlip.ttl() + 1);
        user1.doDeal(address(ethFlip), batchId);

        vow.flog(eraBite);
        vow.heal(rad(180 ether));
        this.file(address(vow), "dump", 0.65 ether);
        this.file(address(vow), bytes32("sump"), rad(20 ether));
        batchId = vow.flop();
        (uint bid,,,,) = flop.bids(batchId);
        assertEq(bid, rad(20 ether));
        user1.doHope(address(vat), address(flop));
        user2.doHope(address(vat), address(flop));
    }

    function testFlop() public {
        deploy();
        uint batchId = _flop();
        user1.doDent(address(flop), batchId, 0.6 ether, rad(20 ether));
        hevm.warp(now + flop.ttl() - 1);
        user2.doDent(address(flop), batchId, 0.2 ether, rad(20 ether));
        user1.doDent(address(flop), batchId, 0.16 ether, rad(20 ether));
        hevm.warp(now + flop.ttl() + 1);
        uint prevGovSupply = gov.totalSupply();
        user1.doDeal(address(flop), batchId);
        assertEq(gov.totalSupply(), prevGovSupply + 0.16 ether);
        vow.kiss(rad(20 ether));
        assertEq(vat.dai(address(vow)), 0);
        assertEq(vat.sin(address(vow)) - vow.Sin() - vow.Ash(), 0);
        assertEq(vat.sin(address(vow)), 0);
    }

    function _flap() internal returns (uint batchId) {
        this.dripAndFile(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 0.5 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vat.dai(address(vow)), 0);
        jug.drip("ETH");
        assertEq(vat.dai(address(vow)), rad(10 * 0.05 ether));
        this.file(address(vow), bytes32("bump"), rad(0.05 ether));
        batchId = vow.flap();

        (,uint lot,,,) = flap.bids(batchId);
        assertEq(lot, rad(0.05 ether));
        user1.doApprove(address(gov), address(flap));
        user2.doApprove(address(gov), address(flap));
        gov.transfer(address(user1), 1 ether);
        gov.transfer(address(user2), 1 ether);

        assertEq(dai.balanceOf(address(user1)), 0);
        assertEq(gov.balanceOf(address(0)), 0);
    }

    function testFlap() public {
        deploy();
        uint batchId = _flap();

        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.001 ether);
        user2.doTend(address(flap), batchId, rad(0.05 ether), 0.0015 ether);
        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.0016 ether);

        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.0016 ether);
        assertEq(gov.balanceOf(address(user2)), 1 ether);
        hevm.warp(now + flap.ttl() + 1);
        assertEq(gov.balanceOf(address(flap)), 0.0016 ether);
        user1.doDeal(address(flap), batchId);
        assertEq(gov.balanceOf(address(flap)), 0);
        user1.doHope(address(vat), address(daiJoin));
        user1.doDaiExit(address(daiJoin), address(user1), 0.05 ether);
        assertEq(dai.balanceOf(address(user1)), 0.05 ether);
    }

    function testEnd() public {
        deploy();
        this.file(address(cat), "ETH", "lump", 1 ether); // 1 unit of collateral per batch
        this.file(address(cat), "ETH", "chop", ONE);
        weth.deposit.value(2 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 2 ether);
        vat.frob("ETH", address(this), address(this), address(this), 2 ether, 400 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        uint batchId = cat.bite("ETH", address(this)); // The CDP remains unsafe after 1st batch is bitten
        address(user1).transfer(10 ether);
        user1.doEthJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        col.mint(100 ether);
        col.approve(address(colJoin), 100 ether);
        colJoin.join(address(user2), 100 ether);
        user2.doFrob(address(vat), "COL", address(user2), address(user2), address(user2), 100 ether, 1000 ether);

        user1.doHope(address(vat), address(ethFlip));
        user2.doHope(address(vat), address(ethFlip));

        user1.doTend(address(ethFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(ethFlip), batchId, 1 ether, rad(140 ether));
        assertEq(vat.dai(address(user2)), rad(860 ether));

        this.cage(address(end));
        end.cage("ETH");
        end.cage("COL");

        (uint ink, uint art) = vat.urns("ETH", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 200 ether);

        end.skip("ETH", batchId);
        assertEq(vat.dai(address(user2)), rad(1000 ether));
        (ink, art) = vat.urns("ETH", address(this));
        assertEq(ink, 2 ether);
        assertEq(art, 400 ether);

        end.skim("ETH", address(this));
        (ink, art) = vat.urns("ETH", address(this));
        uint remainInkVal = 2 ether - 400 * end.tag("ETH") / 10 ** 9; // 2 ETH (deposited) - 400 DAI debt * ETH cage price
        assertEq(ink, remainInkVal);
        assertEq(art, 0);

        end.free("ETH");
        (ink,) = vat.urns("ETH", address(this));
        assertEq(ink, 0);

        (ink, art) = vat.urns("ETH", address(user1));
        assertEq(ink, 10 ether);
        assertEq(art, 1000 ether);

        end.skim("ETH", address(user1));
        end.skim("COL", address(user2));

        vow.heal(vat.dai(address(vow)));

        end.thaw();

        end.flow("ETH");
        end.flow("COL");

        vat.hope(address(end));
        end.pack(400 ether);

        assertEq(vat.gem("ETH", address(this)), remainInkVal);
        assertEq(vat.gem("COL", address(this)), 0);
        end.cash("ETH", 400 ether);
        end.cash("COL", 400 ether);
        assertEq(vat.gem("ETH", address(this)), remainInkVal + 400 * end.fix("ETH") / 10 ** 9);
        assertEq(vat.gem("COL", address(this)), 400 * end.fix("COL") / 10 ** 9);
    }

    function testFlopEnd() public {
        deploy();
        uint batchId = _flop();
        this.cage(address(end));
        flop.yank(batchId);
    }

    function testFlopEndWithBid() public {
        deploy();
        uint batchId = _flop();
        user1.doDent(address(flop), batchId, 0.6 ether, rad(20 ether));
        assertEq(vat.dai(address(user1)), rad(800 ether));
        this.cage(address(end));
        flop.yank(batchId);
        assertEq(vat.dai(address(user1)), rad(820 ether));
    }

    function testFlapEnd() public {
        deploy();
        uint batchId = _flap();

        this.cage(address(end));
        flap.yank(batchId);
    }

    function testFlapEndWithBid() public {
        deploy();
        uint batchId = _flap();

        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.001 ether);
        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.001 ether);

        this.cage(address(end));
        flap.yank(batchId);

        assertEq(gov.balanceOf(address(user1)), 1 ether);
    }

    function testFireESM() public {
        deploy();
        gov.mint(address(user1), 10);

        user1.doESMJoin(address(gov), address(esm), 10);
        esm.fire();
    }

    function testDsr() public {
        deploy();
        this.dripAndFile(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.1 * 10 ** 27));
        this.dripAndFile(address(pot), "dsr", uint(1.05 * 10 ** 27));
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 0.5 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.1 ether, 10 ether);
        assertEq(vat.dai(address(this)), mul(10 ether, ONE));
        vat.hope(address(pot));
        pot.join(10 ether);
        hevm.warp(now + 1);
        jug.drip("ETH");
        pot.drip();
        pot.exit(10 ether);
        assertEq(vat.dai(address(this)), mul(10.5 ether, ONE));
    }

    function testFork() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);
        (uint ink, uint art) = vat.urns("ETH", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("ETH", address(this), address(user1), 0.25 ether, 15 ether);

        (ink, art) = vat.urns("ETH", address(this));
        assertEq(ink, 0.75 ether);
        assertEq(art, 45 ether);

        (ink, art) = vat.urns("ETH", address(user1));
        assertEq(ink, 0.25 ether);
        assertEq(art, 15 ether);
    }

    function testFailFork() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.fork("ETH", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testForkFromOtherUsr() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.hope(address(user1));
        user1.doFork(address(vat), "ETH", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkFromOtherUsr() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);

        user1.doFork(address(vat), "ETH", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkUnsafeSrc() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("ETH", address(this), address(user1), 0.9 ether, 1 ether);
    }

    function testFailForkUnsafeDst() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("ETH", address(this), address(user1), 0.1 ether, 59 ether);
    }

    function testFailForkDustSrc() public {
        deploy();
        weth.deposit.value(100 ether)(); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 100 ether);

        this.file(address(vat), "ETH", "dust", mul(ONE, 20 ether));
        vat.frob("ETH", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("ETH", address(this), address(user1), 50 ether, 19 ether);
    }

    function testFailForkDustDst() public {
        deploy();
        weth.deposit.value(100 ether)(); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 100 ether);

        this.file(address(vat), "ETH", "dust", mul(ONE, 20 ether));
        vat.frob("ETH", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("ETH", address(this), address(user1), 50 ether, 41 ether);
    }

    function testSetPauseAuthority() public {
        deploy();
        assertEq(address(pause.authority()), address(authority));
        this.setAuthority(address(123));
        assertEq(address(pause.authority()), address(123));
    }

    function testSetPauseDelay() public {
        deploy();
        assertEq(pause.delay(), 0);
        this.setDelay(5);
        assertEq(pause.delay(), 5);
    }

    function testSetPauseAuthorityAndDelay() public {
        deploy();
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.delay(), 0);
        this.setAuthorityAndDelay(address(123), 5);
        assertEq(address(pause.authority()), address(123));
        assertEq(pause.delay(), 5);
    }

    function testTokens() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        {
        REP rep = new REP(100 ether);
        GemJoin repJoin = new GemJoin(address(vat), "REP", address(rep));
        assertEq(repJoin.dec(), 18);

        dssDeploy.deployCollateral("REP", address(repJoin), address(pip));

        rep.approve(address(repJoin), uint(-1));
        assertEq(rep.balanceOf(address(this)), 100 ether);
        assertEq(rep.balanceOf(address(repJoin)), 0);
        assertEq(vat.gem("REP", address(this)), 0);
        repJoin.join(address(this), 10 ether);
        assertEq(rep.balanceOf(address(repJoin)), 10 ether);
        assertEq(vat.gem("REP", address(this)), 10 ether);
        repJoin.exit(address(this), 4 ether);
        assertEq(rep.balanceOf(address(this)), 94 ether);
        assertEq(rep.balanceOf(address(repJoin)), 6 ether);
        assertEq(vat.gem("REP", address(this)), 6 ether);
        }

        {
        ZRX zrx = new ZRX(100 ether);
        GemJoin zrxJoin = new GemJoin(address(vat), "ZRX", address(zrx));
        assertEq(zrxJoin.dec(), 18);

        dssDeploy.deployCollateral("ZRX", address(zrxJoin), address(pip));

        zrx.approve(address(zrxJoin), uint(-1));
        assertEq(zrx.balanceOf(address(this)), 100 ether);
        assertEq(zrx.balanceOf(address(zrxJoin)), 0);
        assertEq(vat.gem("ZRX", address(this)), 0);
        zrxJoin.join(address(this), 10 ether);
        assertEq(zrx.balanceOf(address(zrxJoin)), 10 ether);
        assertEq(vat.gem("ZRX", address(this)), 10 ether);
        zrxJoin.exit(address(this), 4 ether);
        assertEq(zrx.balanceOf(address(this)), 94 ether);
        assertEq(zrx.balanceOf(address(zrxJoin)), 6 ether);
        assertEq(vat.gem("ZRX", address(this)), 6 ether);
        }

        {
        OMG omg = new OMG(100 ether);
        GemJoin2 omgJoin = new GemJoin2(address(vat), "OMG", address(omg));
        assertEq(omgJoin.dec(), 18);

        dssDeploy.deployCollateral("OMG", address(omgJoin), address(pip));

        omg.approve(address(omgJoin), uint(-1));
        assertEq(omg.balanceOf(address(this)), 100 ether);
        assertEq(omg.balanceOf(address(omgJoin)), 0);
        assertEq(vat.gem("OMG", address(this)), 0);
        omgJoin.join(address(this), 10 ether);
        assertEq(omg.balanceOf(address(omgJoin)), 10 ether);
        assertEq(vat.gem("OMG", address(this)), 10 ether);
        omgJoin.exit(address(this), 4 ether);
        assertEq(omg.balanceOf(address(this)), 94 ether);
        assertEq(omg.balanceOf(address(omgJoin)), 6 ether);
        assertEq(vat.gem("OMG", address(this)), 6 ether);
        }

        {
        BAT bat = new BAT(100 ether);
        GemJoin batJoin = new GemJoin(address(vat), "BAT", address(bat));
        assertEq(batJoin.dec(), 18);

        dssDeploy.deployCollateral("BAT", address(batJoin), address(pip));

        bat.approve(address(batJoin), uint(-1));
        assertEq(bat.balanceOf(address(this)), 100 ether);
        assertEq(bat.balanceOf(address(batJoin)), 0);
        assertEq(vat.gem("BAT", address(this)), 0);
        batJoin.join(address(this), 10 ether);
        assertEq(bat.balanceOf(address(batJoin)), 10 ether);
        assertEq(vat.gem("BAT", address(this)), 10 ether);
        batJoin.exit(address(this), 4 ether);
        assertEq(bat.balanceOf(address(this)), 94 ether);
        assertEq(bat.balanceOf(address(batJoin)), 6 ether);
        assertEq(vat.gem("BAT", address(this)), 6 ether);
        }

        {
        DGD dgd = new DGD(100 * 10 ** 9);
        GemJoin3 dgdJoin = new GemJoin3(address(vat), "DGD", address(dgd), 9);
        assertEq(dgdJoin.dec(), 9);

        dssDeploy.deployCollateral("DGD", address(dgdJoin), address(pip));

        dgd.approve(address(dgdJoin), uint(-1));
        assertEq(dgd.balanceOf(address(this)), 100 * 10 ** 9);
        assertEq(dgd.balanceOf(address(dgdJoin)), 0);
        assertEq(vat.gem("DGD", address(this)), 0);
        dgdJoin.join(address(this), 10 * 10 ** 9);
        assertEq(dgd.balanceOf(address(dgdJoin)), 10 * 10 ** 9);
        assertEq(vat.gem("DGD", address(this)), 10 ether);
        dgdJoin.exit(address(this), 4 * 10 ** 9);
        assertEq(dgd.balanceOf(address(this)), 94 * 10 ** 9);
        assertEq(dgd.balanceOf(address(dgdJoin)), 6 * 10 ** 9);
        assertEq(vat.gem("DGD", address(this)), 6 ether);
        }

        {
        GNT gnt = new GNT(100 ether);
        GemJoin4 gntJoin = new GemJoin4(address(vat), "GNT", address(gnt));
        assertEq(gntJoin.dec(), 18);

        dssDeploy.deployCollateral("GNT", address(gntJoin), address(pip));

        assertEq(gnt.balanceOf(address(this)), 100 ether);
        assertEq(gnt.balanceOf(address(gntJoin)), 0);
        assertEq(vat.gem("GNT", address(this)), 0);
        address bag = gntJoin.make();
        gnt.transfer(bag, 10 ether);
        gntJoin.join(address(this), 10 ether);
        assertEq(gnt.balanceOf(address(gntJoin)), 10 ether);
        assertEq(vat.gem("GNT", address(this)), 10 ether);
        gntJoin.exit(address(this), 4 ether);
        assertEq(gnt.balanceOf(address(this)), 94 ether);
        assertEq(gnt.balanceOf(address(gntJoin)), 6 ether);
        assertEq(vat.gem("GNT", address(this)), 6 ether);
        }

        {
        USDC usdc = new USDC(100 * 10 ** 6);
        GemJoin5 usdcJoin = new GemJoin5(address(vat), "USDC", address(usdc));
        assertEq(usdcJoin.dec(), 6);

        dssDeploy.deployCollateral("USDC", address(usdcJoin), address(pip));

        usdc.approve(address(usdcJoin), uint(-1));
        assertEq(usdc.balanceOf(address(this)), 100 * 10 ** 6);
        assertEq(usdc.balanceOf(address(usdcJoin)), 0);
        assertEq(vat.gem("USDC", address(this)), 0);
        usdcJoin.join(address(this), 10 * 10 ** 6);
        assertEq(usdc.balanceOf(address(usdcJoin)), 10 * 10 ** 6);
        assertEq(vat.gem("USDC", address(this)), 10 ether);
        usdcJoin.exit(address(this), 4 * 10 ** 6);
        assertEq(usdc.balanceOf(address(this)), 94 * 10 ** 6);
        assertEq(usdc.balanceOf(address(usdcJoin)), 6 * 10 ** 6);
        assertEq(vat.gem("USDC", address(this)), 6 ether);
        }

        {
        WBTC wbtc = new WBTC(100 * 10 ** 8);
        GemJoin5 wbtcJoin = new GemJoin5(address(vat), "WBTC", address(wbtc));
        assertEq(wbtcJoin.dec(), 8);

        dssDeploy.deployCollateral("WBTC", address(wbtcJoin), address(pip));

        wbtc.approve(address(wbtcJoin), uint(-1));
        assertEq(wbtc.balanceOf(address(this)), 100 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 0);
        assertEq(vat.gem("WBTC", address(this)), 0);
        wbtcJoin.join(address(this), 10 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 10 * 10 ** 8);
        assertEq(vat.gem("WBTC", address(this)), 10 ether);
        wbtcJoin.exit(address(this), 4 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(this)), 94 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 6 * 10 ** 8);
        assertEq(vat.gem("WBTC", address(this)), 6 ether);
        }

        {
        TUSD tusd = new TUSD(100 ether);
        GemJoin6 tusdJoin = new GemJoin6(address(vat), "TUSD", address(tusd));
        assertEq(tusdJoin.dec(), 18);

        dssDeploy.deployCollateral("TUSD", address(tusdJoin), address(pip));

        tusd.approve(address(tusdJoin), uint(-1));
        assertEq(tusd.balanceOf(address(this)), 100 ether);
        assertEq(tusd.balanceOf(address(tusdJoin)), 0);
        assertEq(vat.gem("TUSD", address(this)), 0);
        tusdJoin.join(address(this), 10 ether);
        assertEq(tusd.balanceOf(address(tusdJoin)), 10 ether);
        assertEq(vat.gem("TUSD", address(this)), 10 ether);
        tusdJoin.exit(address(this), 4 ether);
        assertEq(tusd.balanceOf(address(this)), 94 ether);
        assertEq(tusd.balanceOf(address(tusdJoin)), 6 ether);
        assertEq(vat.gem("TUSD", address(this)), 6 ether);
        }
    }

    function testFailTUSD() public {
        DSValue pip = new DSValue();
        TUSD tusd = new TUSD(100 ether);
        GemJoin6 tusdJoin = new GemJoin6(address(vat), "TUSD", address(tusd));
        dssDeploy.deployCollateral("TUSD", address(tusdJoin), address(pip));
        tusd.approve(address(tusdJoin), uint(-1));
        assertEq(tusd.balanceOf(address(this)), 100 ether);
        assertEq(tusd.balanceOf(address(tusdJoin)), 0);
        assertEq(vat.gem("TUSD", address(this)), 0);
        tusd.setImplementation(0xCB9a11afDC6bDb92E4A6235959455F28758b34bA);
        // Fail here
        tusdJoin.join(address(this), 10 ether);
    }

    function testFailJoinAfterCageGemJoin2() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        OMG omg = new OMG(100 ether);
        GemJoin2 omgJoin = new GemJoin2(address(vat), "OMG", address(omg));

        dssDeploy.deployCollateral("OMG", address(omgJoin), address(pip));

        omg.approve(address(omgJoin), uint(-1));
        omgJoin.join(address(this), 10);
        omgJoin.cage();
        omgJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin3() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        DGD dgd = new DGD(100 ether);
        GemJoin3 dgdJoin = new GemJoin3(address(vat), "DGD", address(dgd), 9);

        dssDeploy.deployCollateral("DGD", address(dgdJoin), address(pip));

        dgd.approve(address(dgdJoin), uint(-1));
        dgdJoin.join(address(this), 10);
        dgdJoin.cage();
        dgdJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin4() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        GNT gnt = new GNT(100 ether);
        GemJoin4 gntJoin = new GemJoin4(address(vat), "GNT", address(gnt));

        dssDeploy.deployCollateral("GNT", address(gntJoin), address(pip));

        address bag = gntJoin.make();
        gnt.transfer(bag, 10);
        gntJoin.join(address(this), 10);
        gntJoin.cage();
        gnt.transfer(bag, 10);
        gntJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin5() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        USDC usdc = new USDC(100 ether);
        GemJoin5 usdcJoin = new GemJoin5(address(vat), "USDC", address(usdc));

        dssDeploy.deployCollateral("USDC", address(usdcJoin), address(pip));

        usdc.approve(address(usdcJoin), uint(-1));
        usdcJoin.join(address(this), 10);
        usdcJoin.cage();
        usdcJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageAuthGemJoin() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        DSToken sai = new DSToken("SAI");
        sai.mint(20);
        AuthGemJoin saiJoin = new AuthGemJoin(address(vat), "SAI", address(sai));

        dssDeploy.deployCollateral("SAI", address(saiJoin), address(pip));

        sai.approve(address(saiJoin), uint(-1));
        saiJoin.join(address(this), 10);
        saiJoin.cage();
        saiJoin.join(address(this), 10);
    }

    function testTokenSai() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        DSToken sai = new DSToken("SAI");
        sai.mint(10);
        AuthGemJoin saiJoin = new AuthGemJoin(address(vat), "SAI", address(sai));
        assertEq(saiJoin.dec(), 18);

        dssDeploy.deployCollateral("SAI", address(saiJoin), address(pip));

        sai.approve(address(saiJoin), uint(-1));
        assertEq(sai.balanceOf(address(saiJoin)), 0);
        assertEq(vat.gem("SAI", address(this)), 0);
        saiJoin.join(address(this), 10);
        assertEq(sai.balanceOf(address(saiJoin)), 10);
        assertEq(vat.gem("SAI", address(this)), 10);
        saiJoin.deny(address(this)); // Check there is no need of authorization to exit
        saiJoin.exit(address(this), 4);
        assertEq(sai.balanceOf(address(saiJoin)), 6);
        assertEq(vat.gem("SAI", address(this)), 6);
    }

    function testFailTokenSai() public {
        deployKeepAuth();
        DSValue pip = new DSValue();

        DSToken sai = new DSToken("SAI");
        sai.mint(10);
        AuthGemJoin saiJoin = new AuthGemJoin(address(vat), "SAI", address(sai));

        dssDeploy.deployCollateral("SAI", address(saiJoin), address(pip));

        sai.approve(address(saiJoin), uint(-1));
        saiJoin.deny(address(this));
        saiJoin.join(address(this), 10);
    }

    function testAuth() public {
        deployKeepAuth();

        // vat
        assertEq(vat.wards(address(dssDeploy)), 1);
        assertEq(vat.wards(address(ethJoin)), 1);
        assertEq(vat.wards(address(colJoin)), 1);
        assertEq(vat.wards(address(cat)), 1);
        assertEq(vat.wards(address(jug)), 1);
        assertEq(vat.wards(address(spotter)), 1);
        assertEq(vat.wards(address(end)), 1);
        assertEq(vat.wards(address(pause.proxy())), 1);

        // cat
        assertEq(cat.wards(address(dssDeploy)), 1);
        assertEq(cat.wards(address(end)), 1);
        assertEq(cat.wards(address(pause.proxy())), 1);

        // vow
        assertEq(vow.wards(address(dssDeploy)), 1);
        assertEq(vow.wards(address(cat)), 1);
        assertEq(vow.wards(address(end)), 1);
        assertEq(vow.wards(address(pause.proxy())), 1);

        // jug
        assertEq(jug.wards(address(dssDeploy)), 1);
        assertEq(jug.wards(address(pause.proxy())), 1);

        // pot
        assertEq(pot.wards(address(dssDeploy)), 1);
        assertEq(pot.wards(address(pause.proxy())), 1);

        // dai
        assertEq(dai.wards(address(dssDeploy)), 1);

        // spotter
        assertEq(spotter.wards(address(dssDeploy)), 1);
        assertEq(spotter.wards(address(pause.proxy())), 1);

        // flap
        assertEq(flap.wards(address(dssDeploy)), 1);
        assertEq(flap.wards(address(vow)), 1);
        assertEq(flap.wards(address(pause.proxy())), 1);

        // flop
        assertEq(flop.wards(address(dssDeploy)), 1);
        assertEq(flop.wards(address(vow)), 1);
        assertEq(flop.wards(address(pause.proxy())), 1);

        // end
        assertEq(end.wards(address(dssDeploy)), 1);
        assertEq(end.wards(address(esm)), 1);
        assertEq(end.wards(address(pause.proxy())), 1);

        // flips
        assertEq(ethFlip.wards(address(dssDeploy)), 1);
        assertEq(ethFlip.wards(address(end)), 1);
        assertEq(ethFlip.wards(address(pause.proxy())), 1);
        assertEq(colFlip.wards(address(dssDeploy)), 1);
        assertEq(colFlip.wards(address(end)), 1);
        assertEq(colFlip.wards(address(pause.proxy())), 1);

        // pause
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.owner(), address(0));

        // dssDeploy
        assertEq(address(dssDeploy.authority()), address(0));
        assertEq(dssDeploy.owner(), address(this));

        dssDeploy.releaseAuth();
        dssDeploy.releaseAuthFlip("ETH");
        dssDeploy.releaseAuthFlip("COL");
        assertEq(vat.wards(address(dssDeploy)), 0);
        assertEq(cat.wards(address(dssDeploy)), 0);
        assertEq(vow.wards(address(dssDeploy)), 0);
        assertEq(jug.wards(address(dssDeploy)), 0);
        assertEq(pot.wards(address(dssDeploy)), 0);
        assertEq(dai.wards(address(dssDeploy)), 0);
        assertEq(spotter.wards(address(dssDeploy)), 0);
        assertEq(flap.wards(address(dssDeploy)), 0);
        assertEq(flop.wards(address(dssDeploy)), 0);
        assertEq(end.wards(address(dssDeploy)), 0);
        assertEq(ethFlip.wards(address(dssDeploy)), 0);
        assertEq(colFlip.wards(address(dssDeploy)), 0);
    }
}
