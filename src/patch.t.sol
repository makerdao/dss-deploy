pragma solidity ^0.4.24;

import "ds-test/test.sol";
import {DSToken} from "ds-token/token.sol";
import {DSRoles} from "ds-roles/roles.sol";

import "./patch.sol";
import "./DssDeploy.t.sol";

contract PatchTest is DSTest {
    Patch00 public patch;
    CatFab  public catfab;
    VowFab  public vowfab;

    DssDeploy public deploy;

    MomFab  momFab;
    VatFab vatFab;
    PitFab pitFab;
    VowFab vowFab;
    CatFab catFab;
    DripFab dripFab;
    FlipFab flipFab;
    FlopFab flopFab;
    FlapFab flapFab;
    SpotFab spotFab;
    TokenFab tokenFab;
    DaiJoinFab daiJoinFab;
    DaiMoveFab daiMoveFab;

    function setUp() public {
        momFab = new MomFab();
        vatFab = new VatFab();
        pitFab = new PitFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        dripFab = new DripFab();
        flipFab = new FlipFab();
        flopFab = new FlopFab();
        flapFab = new FlapFab();
        spotFab = new SpotFab();
        tokenFab = new TokenFab();
        daiJoinFab = new DaiJoinFab();
        daiMoveFab = new DaiMoveFab();

        deploy = new DssDeploy(vatFab, pitFab, dripFab, vowFab, catFab, tokenFab, daiJoinFab, daiMoveFab, flapFab, flopFab, momFab, flipFab, spotFab);

        DSToken gov = new DSToken("GOV");
        DSValue pipETH = new DSValue();
        DSRoles roles  = new DSRoles();
        roles.setRootUser(this, true);

        deploy.deployVat();
        deploy.deployPit();
        deploy.deployDai();
        deploy.deployTaxation(gov);
        deploy.deployLiquidation(gov);
        deploy.deployMom(roles);

        ETHJoin ethJoin = new ETHJoin(deploy.vat(), "ETH");
        GemMove ethMove = new GemMove(deploy.vat(), "ETH");
        deploy.deployCollateral("ETH", ethJoin, ethMove, pipETH);
        // ^^ mock current deploy

        // stuff actually being used in the patch
        catfab = new CatFab();
        vowfab = new VowFab();

        patch = new Patch00(deploy);  // TODO: deploy address forking from kovan

        roles.setRootUser(patch, true);
    }

    function test_patch() public {
        patch.upgrade_vow(vowfab);
        patch.upgrade_cat(catfab);
        patch.apply();

        Vow vow = patch.vow();
        assertEq(vow.bump(), 10000 ether);
        assertEq(vow.sump(), 10000 ether);
        assertEq(vow.hump(),     0 ether);

        Cat cat = patch.cat();
        (address flip, uint chop, uint lump) = cat.ilks("ETH"); flip;
        assertEq(chop, 1.1E27);
        assertEq(lump, 10000 ether);
    }
}

contract Patch01Test is DSTest {
    Patch01   public patch;
    DssDeploy public deploy;
    DSRoles   public roles;

    MomFab  momFab;
    VatFab vatFab;
    PitFab pitFab;
    VowFab vowFab;
    CatFab catFab;
    DripFab dripFab;
    FlipFab flipFab;
    FlopFab flopFab;
    FlapFab flapFab;
    SpotFab spotFab;
    TokenFab tokenFab;
    DaiJoinFab daiJoinFab;
    DaiMoveFab daiMoveFab;

    function setUp() public {
        momFab = new MomFab();
        vatFab = new VatFab();
        pitFab = new PitFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        dripFab = new DripFab();
        flipFab = new FlipFab();
        flopFab = new FlopFab();
        flapFab = new FlapFab();
        spotFab = new SpotFab();
        tokenFab = new TokenFab();
        daiJoinFab = new DaiJoinFab();
        daiMoveFab = new DaiMoveFab();

        deploy = new DssDeploy(vatFab, pitFab, dripFab, vowFab, catFab, tokenFab, daiJoinFab, daiMoveFab, flapFab, flopFab, momFab, flipFab, spotFab);

        DSToken gov = new DSToken("GOV");
        DSValue pipETH = new DSValue();
        roles  = new DSRoles();
        roles.setRootUser(this, true);

        deploy.deployVat();
        deploy.deployPit();
        deploy.deployDai();
        deploy.deployTaxation(gov);
        deploy.deployLiquidation(gov);
        deploy.deployMom(roles);

        ETHJoin ethJoin = new ETHJoin(deploy.vat(), "ETH");
        GemMove ethMove = new GemMove(deploy.vat(), "ETH");
        deploy.deployCollateral("ETH", ethJoin, ethMove, pipETH);
        // ^^ mock current deploy
    }

    function test_patch() public {
        patch = new Patch01(deploy);  // TODO: deploy address forking from kovan
        roles.setRootUser(patch, true);

        patch.apply();

        deploy.rely(this);
        Vat vat = deploy.vat();
        vat.heal("", bytes32(address(this)), -int(1E27 ether));

        DSToken dai = deploy.dai();
        DaiJoin daiA = deploy.daiJoin();

        assertEq(dai.balanceOf(this), 0 ether);
        daiA.exit(this, 1 ether);
        assertEq(dai.balanceOf(this), 1 ether);
        dai.transfer(address(0), 0.5 ether);
        assertEq(dai.balanceOf(this), 0.5 ether);
    }
}
