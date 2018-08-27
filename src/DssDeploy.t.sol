pragma solidity ^0.4.24;

import {DSTest} from "ds-test/test.sol";
import {DSValue} from "ds-value/value.sol";
import {DSRoles} from "ds-roles/roles.sol";

import {Adapter, ETHAdapter} from "dss/join.sol";
import {GemMove} from 'dss/move.sol';

import "./DssDeploy.sol";

contract DssDeployTest is DSTest {
    VatFab vatFab;
    PitFab pitFab;
    DripFab dripFab;
    VowFab vowFab;
    CatFab catFab;
    TokenFab tokenFab;
    DaiAptFab daiAptFab;
    DaiMoveFab daiMoveFab;
    FlapFab flapFab;
    FlopFab flopFab;
    MomFab momFab;
    FlipFab flipFab;
    PriceFab priceFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipETH;
    DSValue pipDGX;

    DSRoles authority;

    function setUp() public {
        vatFab = new VatFab();
        pitFab = new PitFab();
        dripFab = new DripFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        tokenFab = new TokenFab();
        daiAptFab = new DaiAptFab();
        daiMoveFab = new DaiMoveFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        momFab = new MomFab();

        flipFab = new FlipFab();
        priceFab = new PriceFab();

        uint startGas = gasleft();
        dssDeploy = new DssDeploy(vatFab, pitFab, dripFab, vowFab, catFab, tokenFab, daiAptFab, daiMoveFab, flapFab, flopFab, momFab, flipFab, priceFab);
        uint endGas = gasleft();
        emit log_named_uint("Deploy DssDeploy", startGas - endGas);

        gov = new DSToken("GOV");
        pipETH = new DSValue();
        pipDGX = new DSValue();
        authority = new DSRoles();
        authority.setRootUser(this, true);
    }

    function testDeploy() public {
        uint startGas = gasleft();
        dssDeploy.deployVat();
        uint endGas = gasleft();
        emit log_named_uint("Deploy VAT", startGas - endGas);

        startGas = gasleft();
        dssDeploy.deployPit();
        endGas = gasleft();
        emit log_named_uint("Deploy PIT", startGas - endGas);

        startGas = gasleft();
        dssDeploy.deployDai();
        endGas = gasleft();
        emit log_named_uint("Deploy DAI", startGas - endGas);

        startGas = gasleft();
        dssDeploy.deployTaxation(gov);
        endGas = gasleft();
        emit log_named_uint("Deploy Taxation", startGas - endGas);

        startGas = gasleft();
        dssDeploy.deployLiquidation(gov);
        endGas = gasleft();
        emit log_named_uint("Deploy Liquidation", startGas - endGas);

        startGas = gasleft();
        dssDeploy.deployMom(authority);
        endGas = gasleft();
        emit log_named_uint("Deploy MOM", startGas - endGas);

        startGas = gasleft();
        ETHAdapter ethAdapter = new ETHAdapter(dssDeploy.vat(), "ETH");
        GemMove    ethMove = new GemMove(dssDeploy.vat(), "ETH");
        dssDeploy.deployCollateral("ETH", ethAdapter, ethMove, pipETH);
        endGas = gasleft();
        emit log_named_uint("Deploy ETH", startGas - endGas);

        startGas = gasleft();
        DSToken dgx = new DSToken("DGX");
        Adapter adapterDGX = new Adapter(dssDeploy.vat(), "DGX", dgx);
        GemMove moveDGX = new GemMove(dssDeploy.vat(), "DGX");
        dssDeploy.deployCollateral("DGX", adapterDGX, moveDGX, pipDGX);
        endGas = gasleft();
        emit log_named_uint("Deploy DGX", startGas - endGas);
    }

    function testFailStep() public {
        dssDeploy.deployPit();
    }
}
