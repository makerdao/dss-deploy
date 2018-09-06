pragma solidity ^0.4.24;

import {DSTest} from "ds-test/test.sol";
import {DSValue} from "ds-value/value.sol";
import {DSRoles} from "ds-roles/roles.sol";

import {GemJoin, ETHJoin} from "dss/join.sol";
import {GemMove} from 'dss/move.sol';

import "./DssDeploy.sol";

contract DssDeployTest is DSTest {
    VatFab vatFab;
    PitFab pitFab;
    DripFab dripFab;
    VowFab vowFab;
    CatFab catFab;
    TokenFab tokenFab;
    DaiJoinFab daiJoinFab;
    DaiMoveFab daiMoveFab;
    FlapFab flapFab;
    FlopFab flopFab;
    MomFab momFab;
    FlipFab flipFab;
    SpotFab spotFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipETH;
    DSValue pipDGX;

    DSRoles authority;

    ETHJoin ethJoin;
    GemJoin dgxJoin;

    Vat vat;
    Pit pit;
    Drip drip;
    Vow vow;
    Cat cat;
    Spotter ethPrice;

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
        daiJoinFab = new DaiJoinFab();
        daiMoveFab = new DaiMoveFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        momFab = new MomFab();

        flipFab = new FlipFab();
        spotFab = new SpotFab();

        uint startGas = gasleft();
        dssDeploy = new DssDeploy(vatFab, pitFab, dripFab, vowFab, catFab, tokenFab, daiJoinFab, daiMoveFab, flapFab, flopFab, momFab, flipFab, spotFab);
        uint endGas = gasleft();
        emit log_named_uint("Deploy DssDeploy", startGas - endGas);

        gov = new DSToken("GOV");
        pipETH = new DSValue();
        pipDGX = new DSValue();
        authority = new DSRoles();
        authority.setRootUser(this, true);
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

        ethJoin = new ETHJoin(vat, "ETH");
        GemMove ethMove = new GemMove(vat, "ETH");
        dssDeploy.deployCollateral("ETH", ethJoin, ethMove, pipETH);

        DSToken dgx = new DSToken("DGX");
        dgxJoin = new GemJoin(vat, "DGX", dgx);
        GemMove dgxMove = new GemMove(vat, "DGX");
        dssDeploy.deployCollateral("DGX", dgxJoin, dgxMove, pipDGX);

        // Set Params
        dssDeploy.mom().file(address(pit), bytes32("Line"), uint(10000 ether));
        dssDeploy.mom().file(address(pit), bytes32("ETH"), bytes32("line"), uint(10000 ether));

        pipETH.poke(300 * 10 ** 18); // Price 300 DAI = 1 ETH (precision 18)
        (,,, ethPrice) = dssDeploy.ilks("ETH");
        dssDeploy.mom().file(address(ethPrice), uint(1500000000 ether)); // Liquidation ratio 150%
        ethPrice.poke();
        (uint spot, ) = pit.ilks("ETH");
        assertEq(spot, 300 * ONE * ONE / 1500000000 ether);
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

    function testJoinCollateral() public {
        deploy();
        assertEq(vat.gem("ETH", bytes32(address(this))), 0);
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        assertEq(vat.gem("ETH", bytes32(address(this))), mul(ONE, 1 ether));
    }

    function testExitCollateral() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        ethJoin.exit(address(this), 1 ether);
        assertEq(vat.gem("ETH", bytes32(address(this))), 0);
    }

    function testDrawDai() public {
        deploy();
        assertEq(dssDeploy.dai().balanceOf(address(this)), 0);
        ethJoin.join.value(1 ether)(bytes32(address(this)));

        pit.frob("ETH", 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", bytes32(address(this))), mul(ONE, 0.5 ether));
        assertEq(vat.dai(bytes32(address(this))), mul(ONE, 60 ether));

        dssDeploy.daiJoin().exit(address(this), 60 ether);
        assertEq(dssDeploy.dai().balanceOf(address(this)), 60 ether);
        assertEq(vat.dai(bytes32(address(this))), 0);
    }

    function testDrawDaiLimit() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 DAI max
    }

    function testFailDrawDaiLimit() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 100 ether + 1);
    }

    function testPaybackDai() public {
        deploy();
        ethJoin.join.value(1 ether)(bytes32(address(this)));
        pit.frob("ETH", 0.5 ether, 60 ether);
        dssDeploy.daiJoin().exit(address(this), 60 ether);
        assertEq(dssDeploy.dai().balanceOf(address(this)), 60 ether);
        dssDeploy.dai().approve(dssDeploy.daiJoin(), uint(-1));
        dssDeploy.daiJoin().join(bytes32(address(this)), 60 ether);
        assertEq(dssDeploy.dai().balanceOf(address(this)), 0);

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
        uint flipN = cat.bite("ETH", bytes32(address(this)));
        cat.flip(flipN, 100 ether);
    }

    function() public payable {
    }
}
