// SPDX-License-Identifier: AGPL-3.0-or-later
//
// DssDeploy.t.sol
//
// Copyright (C) 2018-2022 Dai Foundation
//
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

pragma solidity >=0.5.12;

import "./DssDeploy.t.base.sol";

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
        dssDeploy.deployEnd();
    }

    function testFailMissingEnd() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployLiquidator();
        dssDeploy.deployPause(0, address(authority));
    }

    function testFailMissingPause() public {
        dssDeploy.deployVat();
        dssDeploy.deployDai(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployLiquidator();
        dssDeploy.deployESM(address(gov), 10);
    }

    function testJoinETH() public {
        deploy();
        assertEq(vat.gem("ETH", address(this)), 0);
        weth.mint(1 ether);
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
        weth.mint(1 ether);
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
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", address(this)), 0.5 ether);
        assertEq(vat.dai(address(this)), mul(RAY, 60 ether));

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
        weth.mint(1 ether);
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
        weth.mint(1 ether);
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
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
        dai.approve(address(daiJoin), uint(-1));
        daiJoin.join(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 0);

        assertEq(vat.dai(address(this)), mul(RAY, 60 ether));
        vat.frob("ETH", address(this), address(this), address(this), 0 ether, -60 ether);
        assertEq(vat.dai(address(this)), 0);
    }

    function testFrobFromAnotherUser() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.hope(address(user1));
        user1.doFrob(address(vat), "ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailFrobDust() public {
        deploy();
        weth.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 100 ether);

        this.file(address(vat), "ETH", "dust", mul(RAY, 20 ether));
        vat.frob("ETH", address(this), address(this), address(this), 100 ether, 19 ether);
    }

    function testFailFrobFromAnotherUser() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        user1.doFrob(address(vat), "ETH", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailBite() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.5 ether, 100 ether); // Maximun DAI

        cat.bite("ETH", address(this));
    }

    function testBite() public {
        deploy();
        this.file(address(cat), "ETH", "dunk", rad(200 ether)); // 200 DAI max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(cat), "ETH", "chop", WAD);
        weth.mint(1 ether);
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
        this.file(address(cat), "ETH", "dunk", rad(200 ether)); // 200 DAI max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(cat), "ETH", "chop", WAD);
        weth.mint(10 ether);
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
        this.file(address(cat), "ETH", "dunk", rad(200 ether)); // 200 DAI max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(cat), "ETH", "chop", WAD);
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        assertEq(vat.gem("ETH", address(ethFlip)), 0);
        uint batchId = cat.bite("ETH", address(this));
        assertEq(vat.gem("ETH", address(ethFlip)), 1 ether);
        weth.mint(10 ether);
        weth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        weth.mint(10 ether);
        weth.transfer(address(user2), 10 ether);
        user2.doWethJoin(address(weth), address(ethJoin), address(user2), 10 ether);
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

    function testClip() public {
        deploy();
        assertTrue(address(col2Clip.vow()) == address(vow));
        assertTrue(address(col2Clip.dog()) == address(dog));
        this.file(address(dog), "Hole", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(dog), "COL2", "hole", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(dog), "COL2", "chop", WAD);
        col2.mint(1 ether);
        col2.approve(address(col2Join), uint(-1));
        col2Join.join(address(this), 1 ether);
        vat.frob("COL2", address(this), address(this), address(this), 1 ether, 20 ether); // Maximun DAI generated
        pipCOL2.poke(bytes32(uint(30 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("COL2");
        assertEq(vat.gem("COL2", address(col2Clip)), 0);
        uint id = dog.bark("COL2", address(this), address(this));
        assertEq(vat.gem("COL2", address(col2Clip)), 1 ether);

        (, uint256 tab, uint256 lot,,,) = col2Clip.sales(id);
        assertEq(tab, 20 * RAD);
        assertEq(lot, 1 ether);

        weth.mint(10 ether);
        weth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(col2Clip));

        assertEq(vat.gem("COL2", address(this)), 0);
        assertEq(vat.gem("COL2", address(user1)), 0);

        user1.doTake(address(col2Clip), 1, 1 ether, 30 * RAY, address(user1), "");

        (, tab, lot,,,) = col2Clip.sales(id);
        assertEq(tab, 0);
        assertEq(lot, 0);

        uint256 amt = 1 ether;
        assertEq(vat.gem("COL2", address(this)), amt / 3 + 1);
        assertEq(vat.gem("COL2", address(user1)), amt * 2 / 3);
        assertEq(vat.gem("COL2", address(col2Clip)), 0);
    }

    function _flop() internal returns (uint batchId) {
        this.file(address(cat), "ETH", "dunk", rad(200 ether)); // 200 DAI max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(cat), "ETH", "chop", WAD);
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        uint48 eraBite = uint48(now);
        batchId = cat.bite("ETH", address(this));
        weth.mint(10 ether);
        weth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        weth.mint(10 ether);
        weth.transfer(address(user2), 10 ether);
        user2.doWethJoin(address(weth), address(ethJoin), address(user2), 10 ether);
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
        assertEq(vat.dai(address(vow)), 0);
        assertEq(vat.sin(address(vow)) - vow.Sin() - vow.Ash(), 0);
        assertEq(vat.sin(address(vow)), 0);
    }

    function _flap() internal returns (uint batchId) {
        this.dripAndFile(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        weth.mint(0.5 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 0.5 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vat.dai(address(vow)), 0);
        jug.drip("ETH");
        assertEq(vat.dai(address(vow)), rad(10 * 0.05 ether));
        this.file(address(vow), bytes32("bump"), rad(0.05 ether));
        this.file(address(flap), "lid", rad(0.05 ether));
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
        this.file(address(cat), "ETH", "dunk", rad(200 ether)); // 200 DAI max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 DAI max on auction
        this.file(address(cat), "ETH", "chop", WAD);
        weth.mint(2 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 2 ether);
        vat.frob("ETH", address(this), address(this), address(this), 2 ether, 400 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("ETH");
        uint batchId = cat.bite("ETH", address(this)); // The CDP remains unsafe after 1st batch is bitten
        weth.mint(10 ether);
        weth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(weth), address(ethJoin), address(user1), 10 ether);
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
        assertEq(vat.wards(address(pause.proxy())), 1);
        assertEq(ethFlip.wards(address(pause.proxy())), 1);
        assertEq(col2Clip.wards(address(pause.proxy())), 1);
        esm.fire();
        esm.denyProxy(address(ethFlip));
        esm.denyProxy(address(col2Clip));
        assertEq(vat.wards(address(pause.proxy())), 0);
        assertEq(ethFlip.wards(address(pause.proxy())), 0);
        assertEq(col2Clip.wards(address(pause.proxy())), 0);
        assertEq(end.live(), 0);
        assertEq(vat.live(), 0);
    }

    function testDsr() public {
        deploy();
        this.dripAndFile(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.1 * 10 ** 27));
        this.dripAndFile(address(pot), "dsr", uint(1.05 * 10 ** 27));
        weth.mint(0.5 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 0.5 ether);
        vat.frob("ETH", address(this), address(this), address(this), 0.1 ether, 10 ether);
        assertEq(vat.dai(address(this)), mul(10 ether, RAY));
        vat.hope(address(pot));
        pot.join(10 ether);
        hevm.warp(now + 1);
        jug.drip("ETH");
        pot.drip();
        pot.exit(10 ether);
        assertEq(vat.dai(address(this)), mul(10.5 ether, RAY));
    }

    function testFork() public {
        deploy();
        weth.mint(1 ether);
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
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.fork("ETH", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testForkFromOtherUsr() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.hope(address(user1));
        user1.doFork(address(vat), "ETH", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkFromOtherUsr() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);

        user1.doFork(address(vat), "ETH", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkUnsafeSrc() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("ETH", address(this), address(user1), 0.9 ether, 1 ether);
    }

    function testFailForkUnsafeDst() public {
        deploy();
        weth.mint(1 ether);
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 1 ether);

        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("ETH", address(this), address(user1), 0.1 ether, 59 ether);
    }

    function testFailForkDustSrc() public {
        deploy();
        weth.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 100 ether);

        this.file(address(vat), "ETH", "dust", mul(RAY, 20 ether));
        vat.frob("ETH", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("ETH", address(this), address(user1), 50 ether, 19 ether);
    }

    function testFailForkDustDst() public {
        deploy();
        weth.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(address(this), 100 ether);

        this.file(address(vat), "ETH", "dust", mul(RAY, 20 ether));
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

    function testAuth() public {
        deployKeepAuth();

        // vat
        assertEq(vat.wards(address(dssDeploy)), 1);
        assertEq(vat.wards(address(ethJoin)), 1);
        assertEq(vat.wards(address(colJoin)), 1);
        assertEq(vat.wards(address(cat)), 1);
        assertEq(vat.wards(address(dog)), 1);
        assertEq(vat.wards(address(col2Clip)), 1);
        assertEq(vat.wards(address(jug)), 1);
        assertEq(vat.wards(address(spotter)), 1);
        assertEq(vat.wards(address(end)), 1);
        assertEq(vat.wards(address(esm)), 1);
        assertEq(vat.wards(address(pause.proxy())), 1);

        // cat
        assertEq(cat.wards(address(dssDeploy)), 1);
        assertEq(cat.wards(address(end)), 1);
        assertEq(cat.wards(address(pause.proxy())), 1);

        // dog
        assertEq(dog.wards(address(dssDeploy)), 1);
        // assertEq(dog.wards(address(end)), 1);
        assertEq(dog.wards(address(pause.proxy())), 1);

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

        // cure
        assertEq(cure.wards(address(dssDeploy)), 1);
        assertEq(cure.wards(address(end)), 1);
        assertEq(cure.wards(address(pause.proxy())), 1);

        // end
        assertEq(end.wards(address(dssDeploy)), 1);
        assertEq(end.wards(address(esm)), 1);
        assertEq(end.wards(address(pause.proxy())), 1);

        // flips
        assertEq(ethFlip.wards(address(dssDeploy)), 1);
        assertEq(ethFlip.wards(address(end)), 1);
        assertEq(ethFlip.wards(address(pause.proxy())), 1);
        assertEq(ethFlip.wards(address(esm)), 1);
        assertEq(colFlip.wards(address(dssDeploy)), 1);
        assertEq(colFlip.wards(address(end)), 1);
        assertEq(colFlip.wards(address(pause.proxy())), 1);
        assertEq(colFlip.wards(address(esm)), 1);

        // clips
        assertEq(col2Clip.wards(address(dssDeploy)), 1);
        assertEq(col2Clip.wards(address(end)), 1);
        assertEq(col2Clip.wards(address(pause.proxy())), 1);
        assertEq(col2Clip.wards(address(esm)), 1);

        // pause
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.owner(), address(0));

        // dssDeploy
        assertEq(address(dssDeploy.authority()), address(0));
        assertEq(dssDeploy.owner(), address(this));

        dssDeploy.releaseAuth();
        dssDeploy.releaseAuthFlip("ETH");
        dssDeploy.releaseAuthFlip("COL");
        dssDeploy.releaseAuthClip("COL2");
        assertEq(vat.wards(address(dssDeploy)), 0);
        assertEq(cat.wards(address(dssDeploy)), 0);
        assertEq(dog.wards(address(dssDeploy)), 0);
        assertEq(vow.wards(address(dssDeploy)), 0);
        assertEq(jug.wards(address(dssDeploy)), 0);
        assertEq(pot.wards(address(dssDeploy)), 0);
        assertEq(dai.wards(address(dssDeploy)), 0);
        assertEq(spotter.wards(address(dssDeploy)), 0);
        assertEq(flap.wards(address(dssDeploy)), 0);
        assertEq(flop.wards(address(dssDeploy)), 0);
        assertEq(cure.wards(address(dssDeploy)), 0);
        assertEq(end.wards(address(dssDeploy)), 0);
        assertEq(ethFlip.wards(address(dssDeploy)), 0);
        assertEq(colFlip.wards(address(dssDeploy)), 0);
        assertEq(col2Clip.wards(address(dssDeploy)), 0);
    }
}
