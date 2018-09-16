pragma solidity ^0.4.24;

import {DSAuth} from "ds-auth/auth.sol";

contract Setter {
    function file(address) public;
    function file(bytes32, address) public;
    function file(uint) public;
    function file(bytes32, uint) public;
    function file(bytes32, bytes32, uint) public;
    function file(bytes32, bytes32, address) public;
}

contract DaiMom is DSAuth {
    function file(address who, address addr) public auth {
        Setter(who).file(addr);
    }

    function file(address who, bytes32 what, address addr) public auth {
        Setter(who).file(what, addr);
    }

    function file(address who, uint val) public auth {
        Setter(who).file(val);
    }

    function file(address who, bytes32 what, uint val) public auth {
        Setter(who).file(what, val);
    }

    function file(address who, bytes32 ilk, bytes32 what, uint val) public auth {
        Setter(who).file(ilk, what, val);
    }

    function file(address who, bytes32 ilk, bytes32 what, address addr) public auth {
        Setter(who).file(ilk, what, addr);
    }
}
