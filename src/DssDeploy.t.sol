pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "dss/join.sol";


import "ds-value/value.sol";

import "./DssDeploy.sol";
import "./join.sol";

contract DssDeployTest is DSTest {
    VatFab vatFab;
    PitFab pitFab;
    PieFab pieFab;
    VowFab vowFab;
    CatFab catFab;
    FlapFab flapFab;
    FlopFab flopFab;
    FlipFab flipFab;
    PriceFab priceFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipETH;
    DSValue pipDGX;

    // DSRoles authority;

    function setUp() public {
        vatFab = new VatFab();
        pitFab = new PitFab();
        pieFab = new PieFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        flipFab = new FlipFab();
        priceFab = new PriceFab();

        uint startGas = gasleft();
        dssDeploy = new DssDeploy(vatFab, pitFab, pieFab, vowFab, catFab, flapFab, flopFab, flipFab, priceFab);
        uint endGas = gasleft();
        emit log_named_uint("Deploy DssDeploy", startGas - endGas);

        gov = new DSToken("GOV");
        pipETH = new DSValue();
        pipDGX = new DSValue();
        // authority = new DSRoles();
        // authority.setRootUser(this, true);
    }

    function testDeploy() public {
        uint startGas = gasleft();
        dssDeploy.deployContracts(gov);
        uint endGas = gasleft();

        startGas = gasleft();
        AdapterETH adapterETH = new AdapterETH(dssDeploy.vat(), "ETH");
        dssDeploy.deployIlk("ETH", adapterETH, pipETH, 1.5 ether);
        endGas = gasleft();
        emit log_named_uint("Make Vox Tub", startGas - endGas);

        startGas = gasleft();
        DSToken dgx = new DSToken("DGX");
        Adapter adapterDGX = new Adapter(dssDeploy.vat(), "DGX", dgx);
        dssDeploy.deployIlk("DGX", adapterDGX, pipDGX, 1.1 ether);
        endGas = gasleft();
        emit log_named_uint("Make Vox Tub", startGas - endGas);

        startGas = gasleft();
        dssDeploy.configParams();
        endGas = gasleft();
        emit log_named_uint("Config Params", startGas - endGas);

        startGas = gasleft();
        dssDeploy.verifyParams();
        endGas = gasleft();
        emit log_named_uint("Verify Params", startGas - endGas);

        startGas = gasleft();
        dssDeploy.configAuth(/*authority*/);
        endGas = gasleft();
        emit log_named_uint("Config Auth", startGas - endGas);
    }

    function testFailStep() public {
        dssDeploy.configParams();
    }
}
