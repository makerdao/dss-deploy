pragma solidity >=0.5.0;

import "./DssDeploy.t.base.sol";

contract DssDeployTest is DssDeployTestBase {
    function testDeploy() public {
        deploy();
    }

    function testFailDeploy() public {
        dssDeploy.deployPit();
    }

    function testFailDeploy2() public {
        dssDeploy.deployVat();
        dssDeploy.deployTaxation(address(gov));
    }

    function testFailDeploy3() public {
        dssDeploy.deployVat();
        dssDeploy.deployPit();
        dssDeploy.deployDai();
        dssDeploy.deployLiquidation(address(gov));
    }

    function testFailDeploy4() public {
        dssDeploy.deployVat();
        dssDeploy.deployPit();
        dssDeploy.deployDai();
        dssDeploy.deployTaxation(address(gov));
        dssDeploy.deployMom(authority);
    }

    function testJoinETH() public {
        deploy();
        assertEq(vat.gem("ETH", bytes32(bytes20(address(this)))), 0);
        weth.deposit.value(1 ether)();
        assertEq(weth.balanceOf(address(this)), 1 ether);
        weth.approve(address(ethJoin), 1 ether);
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);
        assertEq(weth.balanceOf(address(this)), 0);
        assertEq(vat.gem("ETH", bytes32(bytes20(address(this)))), mul(ONE, 1 ether));
    }

    function testJoinGem() public {
        deploy();
        dgx.mint(1 ether);
        assertEq(dgx.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("DGX", bytes32(bytes20(address(this)))), 0);
        dgx.approve(address(dgxJoin), 1 ether);
        dgxJoin.join(bytes32(bytes20(address(this))), 1 ether);
        assertEq(dgx.balanceOf(address(this)), 0);
        assertEq(vat.gem("DGX", bytes32(bytes20(address(this)))), mul(ONE, 1 ether));
    }

    function testExitETH() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);
        ethJoin.exit(bytes32(bytes20(address(this))), address(this), 1 ether);
        assertEq(vat.gem("ETH", bytes32(bytes20(address(this)))), 0);
    }

    function testExitGem() public {
        deploy();
        dgx.mint(1 ether);
        dgx.approve(address(dgxJoin), 1 ether);
        dgxJoin.join(bytes32(bytes20(address(this))), 1 ether);
        dgxJoin.exit(bytes32(bytes20(address(this))), address(this), 1 ether);
        assertEq(dgx.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("DGX", bytes32(bytes20(address(this)))), 0);
    }

    function testDrawDai() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);

        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", bytes32(bytes20(address(this)))), mul(ONE, 0.5 ether));
        assertEq(vat.dai(bytes32(bytes20(address(this)))), mul(ONE, 60 ether));

        daiJoin.exit(bytes32(bytes20(address(this))), address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        assertEq(vat.dai(bytes32(bytes20(address(this)))), 0);
    }

    function testDrawDaiGem() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        dgx.mint(1 ether);
        dgx.approve(address(dgxJoin), 1 ether);
        dgxJoin.join(bytes32(bytes20(address(this))), 1 ether);

        pit.frob("DGX", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 20 ether);

        daiJoin.exit(bytes32(bytes20(address(this))), address(this), 20 ether);
        assertEq(dai.balanceOf(address(this)), 20 ether);
    }

    function testDrawDaiLimit() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 DAI max
    }

    function testDrawDaiGemLimit() public {
        deploy();
        dgx.mint(1 ether);
        dgx.approve(address(dgxJoin), 1 ether);
        dgxJoin.join(bytes32(bytes20(address(this))), 1 ether);
        pit.frob("DGX", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 20.454545454545454545 ether); // 0.5 * 45 / 1.1 = 20.454545454545454545 DAI max
    }

    function testFailDrawDaiLimit() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether + 1);
    }

    function testFailDrawDaiGemLimit() public {
        deploy();
        dgx.mint(1 ether);
        dgx.approve(address(dgxJoin), 1 ether);
        dgxJoin.join(bytes32(bytes20(address(this))), 1 ether);
        pit.frob("DGX", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 20.454545454545454545 ether + 1);
    }

    function testPaybackDai() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 60 ether);
        daiJoin.exit(bytes32(bytes20(address(this))), address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        dai.approve(address(daiJoin), uint(-1));
        daiJoin.join(bytes32(bytes20(address(this))), 60 ether);
        assertEq(dai.balanceOf(address(this)), 0);

        assertEq(vat.dai(bytes32(bytes20(address(this)))), mul(ONE, 60 ether));
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0 ether, -60 ether);
        assertEq(vat.dai(bytes32(bytes20(address(this)))), 0);
    }

    function testFailBite() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 1 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether); // Maximun DAI

        cat.bite("ETH", bytes32(bytes20(address(this))));
    }

    function testBite() public {
        deploy();
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 0.5 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether); // Maximun DAI generated

        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        ethPrice.poke();

        (uint ink, uint art) = vat.urns("ETH", bytes32(bytes20(address(this))));
        assertEq(ink, 0.5 ether);
        assertEq(art, 100 ether);
        cat.bite("ETH", bytes32(bytes20(address(this))));
        (ink, art) = vat.urns("ETH", bytes32(bytes20(address(this))));
        assertEq(ink, 0);
        assertEq(art, 0);
    }

    function testFlip() public {
        deploy();
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 0.5 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        ethPrice.poke();
        uint nflip = cat.bite("ETH", bytes32(bytes20(address(this))));
        assertEq(vat.gem("ETH", bytes32(bytes20(address(ethFlip)))), 0);
        uint batchId = cat.flip(nflip, 100 ether);
        assertEq(vat.gem("ETH", bytes32(bytes20(address(ethFlip)))), mul(0.5 ether, ONE));
        address(user1).transfer(10 ether);
        user1.doEthJoin(weth, ethJoin, bytes32(bytes20(address(user1))), 10 ether);
        user1.doFrob(pit, "ETH", bytes32(bytes20(address(user1))), bytes32(bytes20(address(user1))), bytes32(bytes20(address(user1))), 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(weth, ethJoin, bytes32(bytes20(address(user2))), 10 ether);
        user2.doFrob(pit, "ETH", bytes32(bytes20(address(user2))), bytes32(bytes20(address(user2))), bytes32(bytes20(address(user2))), 10 ether, 1000 ether);

        user1.doHope(daiMove, address(ethFlip));
        user2.doHope(daiMove, address(ethFlip));

        user1.doTend(address(ethFlip), batchId, 0.5 ether, 50 ether);
        user2.doTend(address(ethFlip), batchId, 0.5 ether, 70 ether);
        user1.doTend(address(ethFlip), batchId, 0.5 ether, 90 ether);
        user2.doTend(address(ethFlip), batchId, 0.5 ether, 100 ether);

        user1.doDent(address(ethFlip), batchId, 0.4 ether, 100 ether);
        user2.doDent(address(ethFlip), batchId, 0.35 ether, 100 ether);
        hevm.warp(ethFlip.ttl() - 1);
        user1.doDent(address(ethFlip), batchId, 0.3 ether, 100 ether);
        hevm.warp(now + ethFlip.ttl() + 1);
        user1.doDeal(address(ethFlip), batchId);
    }

    function testFlop() public {
        deploy();
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 0.5 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        ethPrice.poke();
        uint48 eraBite = uint48(now);
        uint nflip = cat.bite("ETH", bytes32(bytes20(address(this))));
        uint batchId = cat.flip(nflip, 100 ether);
        address(user1).transfer(10 ether);
        user1.doEthJoin(weth, ethJoin, bytes32(bytes20(address(user1))), 10 ether);
        user1.doFrob(pit, "ETH", bytes32(bytes20(address(user1))), bytes32(bytes20(address(user1))), bytes32(bytes20(address(user1))), 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(weth, ethJoin, bytes32(bytes20(address(user2))), 10 ether);
        user2.doFrob(pit, "ETH", bytes32(bytes20(address(user2))), bytes32(bytes20(address(user2))), bytes32(bytes20(address(user2))), 10 ether, 1000 ether);

        user1.doHope(daiMove, address(ethFlip));
        user2.doHope(daiMove, address(ethFlip));

        user1.doTend(address(ethFlip), batchId, 0.5 ether, 50 ether);
        user2.doTend(address(ethFlip), batchId, 0.5 ether, 70 ether);
        user1.doTend(address(ethFlip), batchId, 0.5 ether, 90 ether);

        hevm.warp(now + ethFlip.ttl() + 1);
        user1.doDeal(address(ethFlip), batchId);

        vow.flog(eraBite);
        vow.heal(90 ether);
        this.file(address(vow), bytes32("sump"), uint(10 ether));
        batchId = vow.flop();

        (uint bid,,,,,) = flop.bids(batchId);
        assertEq(bid, 10 ether);
        user1.doHope(daiMove, address(flop));
        user2.doHope(daiMove, address(flop));
        user1.doDent(address(flop), batchId, 0.3 ether, 10 ether);
        hevm.warp(now + flop.ttl() - 1);
        user2.doDent(address(flop), batchId, 0.1 ether, 10 ether);
        user1.doDent(address(flop), batchId, 0.08 ether, 10 ether);
        hevm.warp(now + flop.ttl() + 1);
        uint prevGovSupply = gov.totalSupply();
        user1.doDeal(address(flop), batchId);
        assertEq(gov.totalSupply(), prevGovSupply + 0.08 ether);
        vow.kiss(10 ether);
        assertEq(vow.Joy(), 0);
        assertEq(vow.Woe(), 0);
        assertEq(vow.Awe(), 0);
    }

    function testFlap() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(bytes32(bytes20(address(this))), 0.5 ether);
        pit.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vow.Joy(), 0);
        drip.drip("ETH");
        assertEq(vow.Joy(), 10 * 0.05 * 10 ** 18);
        this.file(address(vow), bytes32("bump"), uint(0.05 ether));
        uint batchId = vow.flap();

        (,uint lot,,,,) = flap.bids(batchId);
        assertEq(lot, 0.05 ether);
        user1.doApprove(gov, address(flap));
        user2.doApprove(gov, address(flap));
        gov.transfer(address(user1), 1 ether);
        gov.transfer(address(user2), 1 ether);

        assertEq(dai.balanceOf(address(user1)), 0);
        assertEq(gov.balanceOf(address(0)), 0);

        user1.doTend(address(flap), batchId, 0.05 ether, 0.001 ether);
        user2.doTend(address(flap), batchId, 0.05 ether, 0.0015 ether);
        user1.doTend(address(flap), batchId, 0.05 ether, 0.0016 ether);

        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.0016 ether);
        assertEq(gov.balanceOf(address(user2)), 1 ether);
        hevm.warp(now + flap.ttl() + 1);
        user1.doDeal(address(flap), batchId);
        assertEq(gov.balanceOf(address(0)), 0.0016 ether);
        user1.doDaiExit(daiJoin, bytes32(bytes20(address(user1))), address(user1), 0.05 ether);
        assertEq(dai.balanceOf(address(user1)), 0.05 ether);
    }

    function testAuth() public {
        deploy();

        // vat
        assertEq(vat.wards(address(dssDeploy)), 1);

        assertEq(vat.wards(address(ethJoin)), 1);
        assertEq(vat.wards(address(ethMove)), 1);

        assertEq(vat.wards(address(dgxJoin)), 1);
        assertEq(vat.wards(address(dgxMove)), 1);

        assertEq(vat.wards(address(daiJoin)), 1);
        assertEq(vat.wards(address(daiMove)), 1);

        assertEq(vat.wards(address(vow)), 1);
        assertEq(vat.wards(address(cat)), 1);
        assertEq(vat.wards(address(pit)), 1);
        assertEq(vat.wards(address(drip)), 1);

        // dai
        assertEq(address(dai.authority()), address(guard));
        assertTrue(guard.canCall(address(daiJoin), address(dai), bytes4(keccak256("mint(address,uint256)"))));
        assertTrue(guard.canCall(address(daiJoin), address(dai), bytes4(keccak256("burn(address,uint256)"))));

        // flop
        assertEq(flop.wards(address(dssDeploy)), 1);
        assertEq(flop.wards(address(vow)), 1);

        // vow
        assertEq(vow.wards(address(dssDeploy)), 1);
        assertEq(vow.wards(address(mom)), 1);
        assertEq(vow.wards(address(cat)), 1);

        // cat
        assertEq(cat.wards(address(dssDeploy)), 1);
        assertEq(cat.wards(address(mom)), 1);

        // pit
        assertEq(pit.wards(address(dssDeploy)), 1);
        assertEq(pit.wards(address(mom)), 1);
        assertEq(pit.wards(address(ethPrice)), 1);
        assertEq(pit.wards(address(dgxPrice)), 1);

        // spotters
        assertEq(ethPrice.wards(address(dssDeploy)), 1);
        assertEq(ethPrice.wards(address(mom)), 1);

        assertEq(dgxPrice.wards(address(dssDeploy)), 1);
        assertEq(dgxPrice.wards(address(mom)), 1);

        // drip
        assertEq(drip.wards(address(dssDeploy)), 1);
        assertEq(drip.wards(address(mom)), 1);

        // mom
        assertEq(address(mom.authority()), address(authority));
        assertEq(mom.owner(), address(0));

        // dssDeploy
        assertEq(address(dssDeploy.authority()), address(authority));
        assertEq(dssDeploy.owner(), address(0));

        // root
        assertTrue(authority.isUserRoot(address(this)));

        // guard
        assertEq(address(guard.authority()), address(authority));
        assertEq(guard.owner(), address(this));
    }
}
