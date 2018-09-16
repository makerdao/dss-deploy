pragma solidity ^0.4.24;

contract Setter {
    function file(address) public;
    function file(uint) public;
    function file(bytes32, address) public;
    function file(bytes32, uint) public;
    function file(bytes32, bytes32) public;
    function file(bytes32, bytes32, uint) public;
    function file(bytes32, bytes32, address) public;
    function rely(address) public;
    function deny(address) public;
}

contract MomLib {
    function file(address who, address data) public {
        Setter(who).file(data);
    }

    function file(address who, uint data) public {
        Setter(who).file(data);
    }

    function file(address who, bytes32 what, address data) public {
        Setter(who).file(what, data);
    }

    function file(address who, bytes32 what, uint data) public {
        Setter(who).file(what, data);
    }

    function file(address who, bytes32 what, bytes32 data) public {
        Setter(who).file(what, data);
    }

    function file(address who, bytes32 ilk, bytes32 what, uint data) public {
        Setter(who).file(ilk, what, data);
    }

    function file(address who, bytes32 ilk, bytes32 what, address data) public {
        Setter(who).file(ilk, what, data);
    }

    function rely(address who, address to) public {
        Setter(who).rely(to);
    }

    function deny(address who, address to) public {
        Setter(who).deny(to);
    }
}
