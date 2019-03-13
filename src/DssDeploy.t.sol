pragma solidity >=0.5.0;

import "./DssDeploy.t.base.sol";

import "./join.sol";

import "./token1.sol";
import "./token2.sol";
import "./token3.sol";
import "./token4.sol";
import "./token5.sol";

contract DssDeployTest is DssDeployTestBase {
    function testDeploy() public {
        deploy();
    }

    function testFailDeploy() public {
        dssDeploy.deployTaxation(address(gov));
    }

    function testFailDeploy2() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai();
        dssDeploy.deployLiquidation(address(gov));
    }

    function testFailDeploy3() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai();
        dssDeploy.deployTaxation(address(gov));
        dssDeploy.deployMom(authority);
    }

    function testJoinETH() public {
        deploy();
        assertEq(vat.gem("ETH", urn), 0);
        weth.deposit.value(1 ether)();
        assertEq(weth.balanceOf(address(this)), 1 ether);
        weth.approve(address(ethJoin), 1 ether);
        ethJoin.join(urn, 1 ether);
        assertEq(weth.balanceOf(address(this)), 0);
        assertEq(vat.gem("ETH", urn), 1 ether);
    }

    function testJoinGem() public {
        deploy();
        col.mint(1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", urn), 0);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(urn, 1 ether);
        assertEq(col.balanceOf(address(this)), 0);
        assertEq(vat.gem("COL", urn), 1 ether);
    }

    function testExitETH() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        ethJoin.exit(urn, address(this), 1 ether);
        assertEq(vat.gem("ETH", urn), 0);
    }

    function testExitGem() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(urn, 1 ether);
        colJoin.exit(urn, address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", urn), 0);
    }

    function testFrobDrawDai() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", urn), 0.5 ether);
        assertEq(vat.dai(urn), mul(ONE, 60 ether));

        daiJoin.exit(urn, address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        assertEq(vat.dai(urn), 0);
    }

    function testFrobDrawDaiGem() public {
        deploy();
        assertEq(dai.balanceOf(address(this)), 0);
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(urn, 1 ether);

        vat.frob("COL", urn, urn, urn, 0.5 ether, 20 ether);

        daiJoin.exit(urn, address(this), 20 ether);
        assertEq(dai.balanceOf(address(this)), 20 ether);
    }

    function testFrobDrawDaiLimit() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 DAI max
    }

    function testFrobDrawDaiGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(urn, 1 ether);
        vat.frob("COL", urn, urn, urn, 0.5 ether, 20.454545454545454545 ether); // 0.5 * 45 / 1.1 = 20.454545454545454545 DAI max
    }

    function testFailFrobDrawDaiLimit() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 100 ether + 1);
    }

    function testFailFrobDrawDaiGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(urn, 1 ether);
        vat.frob("COL", urn, urn, urn, 0.5 ether, 20.454545454545454545 ether + 1);
    }

    function testFrobPaybackDai() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 60 ether);
        daiJoin.exit(urn, address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        dai.approve(address(daiJoin), uint(-1));
        daiJoin.join(urn, 60 ether);
        assertEq(dai.balanceOf(address(this)), 0);

        assertEq(vat.dai(urn), mul(ONE, 60 ether));
        vat.frob("ETH", urn, urn, urn, 0 ether, -60 ether);
        assertEq(vat.dai(urn), 0);
    }

    function testFrobFromAnotherUser() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        vat.hope(address(user1));
        user1.doFrob(address(vat), "ETH", urn, urn, urn, 0.5 ether, 60 ether);
    }

    function testFailFrobDust() public {
        deploy();
        weth.deposit.value(100 ether)(); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 100 ether);

        this.file(address(vat), "ETH", "dust", mul(ONE, 20 ether));
        vat.frob("ETH", urn, urn, urn, 100 ether, 19 ether);
    }

    function testFailFrobFromAnotherUser() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        user1.doFrob(address(vat), "ETH", urn, urn, urn, 0.5 ether, 60 ether);
    }

    function testFailBite() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 100 ether); // Maximun DAI

        cat.bite("ETH", urn);
    }

    function testBite() public {
        deploy();
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 0.5 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 100 ether); // Maximun DAI generated

        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");

        (uint ink, uint art) = vat.urns("ETH", urn);
        assertEq(ink, 0.5 ether);
        assertEq(art, 100 ether);
        cat.bite("ETH", urn);
        (ink, art) = vat.urns("ETH", urn);
        assertEq(ink, 0);
        assertEq(art, 0);
    }

    function testFlip() public {
        deploy();
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 0.5 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 100 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        uint nflip = cat.bite("ETH", urn);
        assertEq(vat.gem("ETH", bytes32(bytes20(address(ethFlip)))), 0);
        uint batchId = cat.flip(nflip, 100 ether);
        assertEq(vat.gem("ETH", bytes32(bytes20(address(ethFlip)))), 0.5 ether);
        address(user1).transfer(10 ether);
        bytes32 user1Urn = bytes32(bytes20(address(user1)));
        user1.doEthJoin(address(weth), address(ethJoin), user1Urn, 10 ether);
        user1.doFrob(address(vat), "ETH", user1Urn, user1Urn, user1Urn, 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        bytes32 user2Urn = bytes32(bytes20(address(user2)));
        user2.doEthJoin(address(weth), address(ethJoin), user2Urn, 10 ether);
        user2.doFrob(address(vat), "ETH", user2Urn, user2Urn, user2Urn, 10 ether, 1000 ether);

        user1.doHope(address(daiMove), address(ethFlip));
        user2.doHope(address(daiMove), address(ethFlip));

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
        ethJoin.join(urn, 0.5 ether);
        vat.frob("ETH", urn, urn, urn, 0.5 ether, 100 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        uint48 eraBite = uint48(now);
        uint nflip = cat.bite("ETH", urn);
        uint batchId = cat.flip(nflip, 100 ether);
        address(user1).transfer(10 ether);
        bytes32 user1Urn = bytes32(bytes20(address(user1)));
        user1.doEthJoin(address(weth), address(ethJoin), user1Urn, 10 ether);
        user1.doFrob(address(vat), "ETH", user1Urn, user1Urn, user1Urn, 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        bytes32 user2Urn = bytes32(bytes20(address(user2)));
        user2.doEthJoin(address(weth), address(ethJoin), user2Urn, 10 ether);
        user2.doFrob(address(vat), "ETH", user2Urn, user2Urn, user2Urn, 10 ether, 1000 ether);

        user1.doHope(address(daiMove), address(ethFlip));
        user2.doHope(address(daiMove), address(ethFlip));

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
        user1.doHope(address(daiMove), address(flop));
        user2.doHope(address(daiMove), address(flop));
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
        this.file(address(jug), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 0.5 ether);
        vat.frob("ETH", urn, urn, urn, 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vow.Joy(), 0);
        jug.drip("ETH");
        assertEq(vow.Joy(), 10 * 0.05 * 10 ** 18);
        this.file(address(vow), bytes32("bump"), uint(0.05 ether));
        uint batchId = vow.flap();

        (,uint lot,,,,) = flap.bids(batchId);
        assertEq(lot, 0.05 ether);
        user1.doApprove(address(gov), address(flap));
        user2.doApprove(address(gov), address(flap));
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
        user1.doDaiExit(address(daiJoin), bytes32(bytes20(address(user1))), address(user1), 0.05 ether);
        assertEq(dai.balanceOf(address(user1)), 0.05 ether);
    }

    function testDsr() public {
        deploy();
        this.file(address(jug), bytes32("ETH"), bytes32("tax"), uint(1.1 * 10 ** 27));
        this.file(address(pot), "dsr", uint(1.05 * 10 ** 27));
        weth.deposit.value(0.5 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 0.5 ether);
        vat.frob("ETH", urn, urn, urn, 0.1 ether, 10 ether);
        assertEq(vat.dai(urn), mul(10 ether, ONE));
        pot.save(urn, 10 ether);
        hevm.warp(now + 1);
        jug.drip("ETH");
        pot.drip();
        pot.save(urn, -int(10 ether));
        assertEq(vat.dai(urn), mul(10.5 ether, ONE));
    }

    function testFork() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);
        (uint ink, uint art) = vat.urns("ETH", urn);
        assertEq(ink, 1 ether);
        assertEq(art, 60 ether);

        bytes32 otherOwnedUrn = bytes32(uint(address(this)) * 2 ** (12 * 8) + uint96(1));
        vat.fork("ETH", urn, otherOwnedUrn, 0.25 ether, 15 ether);

        (ink, art) = vat.urns("ETH", urn);
        assertEq(ink, 0.75 ether);
        assertEq(art, 45 ether);

        (ink, art) = vat.urns("ETH", otherOwnedUrn);
        assertEq(ink, 0.25 ether);
        assertEq(art, 15 ether);
    }

    function testForkNotOwnedUrn() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);
        (uint ink, uint art) = vat.urns("ETH", urn);
        assertEq(ink, 1 ether);
        assertEq(art, 60 ether);

        bytes32 notOwnedUrn = bytes32(bytes20(address(user1)));
        user1.doHope(address(vat), address(this));
        vat.fork("ETH", urn, notOwnedUrn, 0.25 ether, 15 ether);

        (ink, art) = vat.urns("ETH", urn);
        assertEq(ink, 0.75 ether);
        assertEq(art, 45 ether);

        (ink, art) = vat.urns("ETH", notOwnedUrn);
        assertEq(ink, 0.25 ether);
        assertEq(art, 15 ether);
    }

    function testFailForkNotOwnedUrn() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);

        bytes32 notOwnedUrn = bytes32(bytes20(address(user1)));
        vat.fork("ETH", urn, notOwnedUrn, 0.25 ether, 15 ether);
    }

    function testForkFromOtherUsr() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);

        bytes32 notOwnedUrn = bytes32(bytes20(address(user1)));
        vat.hope(address(user1));
        user1.doFork(address(vat), "ETH", urn, notOwnedUrn, 0.25 ether, 15 ether);
    }

    function testFailForkFromOtherUsr() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);

        bytes32 notOwnedUrn = bytes32(bytes20(address(user1)));
        user1.doFork(address(vat), "ETH", urn, notOwnedUrn, 0.25 ether, 15 ether);
    }

    function testFailForkUnsafeSrc() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);
        bytes32 notOwnedUrn = bytes32(bytes20(address(user1)));
        vat.fork("ETH", urn, notOwnedUrn, 0.9 ether, 1 ether);
    }

    function testFailForkUnsafeDst() public {
        deploy();
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 1 ether);

        vat.frob("ETH", urn, urn, urn, 1 ether, 60 ether);
        bytes32 notOwnedUrn = bytes32(bytes20(address(user1)));
        vat.fork("ETH", urn, notOwnedUrn, 0.1 ether, 59 ether);
    }

    function testFailForkDustSrc() public {
        deploy();
        weth.deposit.value(100 ether)(); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 100 ether);

        this.file(address(vat), "ETH", "dust", mul(ONE, 20 ether));
        vat.frob("ETH", urn, urn, urn, 100 ether, 60 ether);

        bytes32 otherOwnedUrn = bytes32(uint(address(this)) * 2 ** (12 * 8) + uint96(1));
        vat.fork("ETH", urn, otherOwnedUrn, 50 ether, 19 ether);
    }

    function testFailForkDustDst() public {
        deploy();
        weth.deposit.value(100 ether)(); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(urn, 100 ether);

        this.file(address(vat), "ETH", "dust", mul(ONE, 20 ether));
        vat.frob("ETH", urn, urn, urn, 100 ether, 60 ether);

        bytes32 otherOwnedUrn = bytes32(uint(address(this)) * 2 ** (12 * 8) + uint96(1));
        vat.fork("ETH", urn, otherOwnedUrn, 50 ether, 41 ether);
    }

    function testTokens() public {
        deploy();
        DSValue pip = new DSValue();
        Token1 token1 = new Token1(100 ether);
        GemJoin col1Join = new GemJoin(address(vat), "COL1", address(token1));
        Token2 token2 = new Token2(100 ether);
        GemJoin col2Join = new GemJoin(address(vat), "COL2", address(token2));
        Token3 token3 = new Token3(100 ether);
        GemJoin2 col3Join = new GemJoin2(address(vat), "COL3", address(token3));
        Token4 token4 = new Token4(100 ether);
        GemJoin col4Join = new GemJoin(address(vat), "COL4", address(token4));
        Token5 token5 = new Token5(100 ether);
        GemJoin3 col5Join = new GemJoin3(address(vat), "COL5", address(token5));

        dssDeploy.deployCollateral("COL1", address(col1Join), address(1), address(pip));
        dssDeploy.deployCollateral("COL2", address(col2Join), address(1), address(pip));
        dssDeploy.deployCollateral("COL3", address(col3Join), address(1), address(pip));
        dssDeploy.deployCollateral("COL4", address(col4Join), address(1), address(pip));
        dssDeploy.deployCollateral("COL5", address(col5Join), address(1), address(pip));

        token1.approve(address(col1Join), uint(-1));
        assertEq(token1.balanceOf(address(col1Join)), 0);
        assertEq(vat.gem("COL1", urn), 0);
        col1Join.join(urn, 10);
        assertEq(token1.balanceOf(address(col1Join)), 10);
        assertEq(vat.gem("COL1", urn), 10);

        token2.approve(address(col2Join), uint(-1));
        assertEq(token2.balanceOf(address(col2Join)), 0);
        assertEq(vat.gem("COL2", urn), 0);
        col2Join.join(urn, 10);
        assertEq(token2.balanceOf(address(col2Join)), 10);
        assertEq(vat.gem("COL2", urn), 10);

        token3.approve(address(col3Join), uint(-1));
        assertEq(token3.balanceOf(address(col3Join)), 0);
        assertEq(vat.gem("COL3", urn), 0);
        col3Join.join(urn, 10);
        assertEq(token3.balanceOf(address(col3Join)), 10);
        assertEq(vat.gem("COL3", urn), 10);

        token4.approve(address(col4Join), uint(-1));
        assertEq(token1.balanceOf(address(col4Join)), 0);
        assertEq(vat.gem("COL4", urn), 0);
        col4Join.join(urn, 10);
        assertEq(token4.balanceOf(address(col4Join)), 10);
        assertEq(vat.gem("COL4", urn), 10);

        token5.approve(address(col5Join), uint(-1));
        assertEq(token1.balanceOf(address(col5Join)), 0);
        assertEq(vat.gem("COL5", urn), 0);
        col5Join.join(urn, 10);
        assertEq(token5.balanceOf(address(col5Join)), 10);
        assertEq(vat.gem("COL5", urn), 10 * 10 ** 9);
    }

    function testAuth() public {
        deploy();

        // vat
        assertEq(vat.wards(address(dssDeploy)), 1);

        assertEq(vat.wards(address(ethJoin)), 1);
        assertEq(vat.wards(address(ethMove)), 1);

        assertEq(vat.wards(address(colJoin)), 1);
        assertEq(vat.wards(address(colMove)), 1);

        assertEq(vat.wards(address(daiJoin)), 1);
        assertEq(vat.wards(address(daiMove)), 1);

        assertEq(vat.wards(address(vow)), 1);
        assertEq(vat.wards(address(cat)), 1);
        assertEq(vat.wards(address(jug)), 1);
        assertEq(vat.wards(address(spotter)), 1);

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

        // spotter
        assertEq(spotter.wards(address(dssDeploy)), 1);
        assertEq(spotter.wards(address(mom)), 1);

        // jug
        assertEq(jug.wards(address(dssDeploy)), 1);
        assertEq(jug.wards(address(mom)), 1);

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
