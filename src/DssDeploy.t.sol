pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./DssDeploy.sol";

contract DssDeployTest is DSTest {
    DssDeploy deploy;

    function setUp() public {
        deploy = new DssDeploy();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
