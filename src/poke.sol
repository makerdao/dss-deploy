pragma solidity >=0.5.0;

contract PitLike {
    function file(bytes32, bytes32, uint) public;
}

contract PipLike {
    function peek() public returns (bytes32, bool);
}

contract Spotter {
    PitLike public pit;
    mapping (bytes32 => Ilk) public ilks;
    uint256 public par = 10 ** 27; // dai per usd

    struct Ilk {
        PipLike pip;
        uint256 mat;
    }

    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1;  }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Init ---
    constructor(address pit_) public {
        wards[msg.sender] = 1;
        pit = PitLike(pit_);
    }

    // --- Math ---
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    // --- Administration ---
    function file(bytes32 ilk, address pip_) public auth {
        ilks[ilk].pip = PipLike(pip_);
    }

    function file(bytes32 what, uint data) public auth {
        if (what == "par") par = data;
    }

    function file(bytes32 ilk, bytes32 what, uint data) public auth {
        if (what == "mat") ilks[ilk].mat = data;
    }

    // --- Update value ---
    function poke(bytes32 ilk) public {
        (bytes32 val, bool zzz) = ilks[ilk].pip.peek();
        if (zzz) {
            pit.file(ilk, "spot", mul(mul(uint(val), 10 ** 9), par) / ilks[ilk].mat);
        }
    }
}
