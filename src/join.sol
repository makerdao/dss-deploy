/// join.sol -- Non-standard token adapters

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
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

import "dss/lib.sol";

interface VatLike {
    function slip(bytes32,address,int) external;
}

// GemJoin2

// For a token that does not return a bool on transfer or transferFrom (like OMG)
// This is one way of doing it. Check the balances before and after calling a transfer

interface GemLike2 {
    function decimals() external view returns (uint);
    function transfer(address,uint) external;
    function transferFrom(address,address,uint) external;
    function balanceOf(address) external view returns (uint);
    function allowance(address,address) external view returns (uint);
}

contract GemJoin2 is LibNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike2 public gem;
    uint     public dec;
    uint     public live;  // Access Flag

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike2(gem_);
        dec = gem.decimals();
    }

    function cage() external note auth {
        live = 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "GemJoin2/overflow");
    }

    function join(address urn, uint wad) public note {
        require(live == 1, "GemJoin2/not-live");
        require(wad <= 2 ** 255, "GemJoin2/overflow");
        vat.slip(ilk, urn, int(wad));
        uint256 prevBalance = gem.balanceOf(msg.sender);

        require(prevBalance >= wad, "GemJoin2/no-funds");
        require(gem.allowance(msg.sender, address(this)) >= wad, "GemJoin2/no-allowance");

        (bool ok,) = address(gem).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), wad)
        );
        require(ok, "GemJoin2/failed-transfer");

        require(prevBalance - wad == gem.balanceOf(msg.sender), "GemJoin2/failed-transfer");
    }

    function exit(address guy, uint wad) public note {
        require(wad <= 2 ** 255, "GemJoin2/overflow");
        vat.slip(ilk, msg.sender, -int(wad));
        uint256 prevBalance = gem.balanceOf(address(this));

        require(prevBalance >= wad, "GemJoin2/no-funds");

        (bool ok,) = address(gem).call(
            abi.encodeWithSignature("transfer(address,uint256)", guy, wad)
        );
        require(ok, "GemJoin2/failed-transfer");

        require(prevBalance - wad == gem.balanceOf(address(this)), "GemJoin2/failed-transfer");
    }
}

// GemJoin3
// For a token that has a lower precision than 18 and doesn't have decimals field in place (like DGD)

interface GemLike3 {
    function transfer(address,uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
}

contract GemJoin3 is LibNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike3 public gem;
    uint     public dec;
    uint     public live;  // Access Flag

    constructor(address vat_, bytes32 ilk_, address gem_, uint decimals) public {
        require(decimals < 18, "GemJoin3/decimals-18-or-higher");
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike3(gem_);
        dec = decimals;
    }

    function cage() external note auth {
        live = 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "GemJoin3/overflow");
    }

    function join(address urn, uint wad) public note {
        require(live == 1, "GemJoin3/not-live");
        uint wad18 = mul(wad, 10 ** (18 - dec));
        require(wad18 <= 2 ** 255, "GemJoin3/overflow");
        vat.slip(ilk, urn, int(wad18));
        require(gem.transferFrom(msg.sender, address(this), wad), "GemJoin3/failed-transfer");
    }

    function exit(address guy, uint wad) public note {
        uint wad18 = mul(wad, 10 ** (18 - dec));
        require(wad18 <= 2 ** 255, "GemJoin3/overflow");
        vat.slip(ilk, msg.sender, -int(wad18));
        require(gem.transfer(guy, wad), "GemJoin3/failed-transfer");
    }
}

/// GemJoin4

// Copyright (C) 2019 Lorenzo Manacorda <lorenzo@mailbox.org>
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

// For tokens that do not implement transferFrom (like GNT), meaning the usual adapter
// approach won't work: the adapter cannot call transferFrom and therefore
// has no way of knowing when users deposit gems into it.

// To work around this, we introduce the concept of a bag, which is a trusted
// (it's created by the adapter), personalized component (one for each user).

// Users first have to create their bag with `GemJoin4.make`, then transfer
// gem to it, and then call `GemJoin4.join`, which transfer the gems from the
// bag to the adapter.

interface GemLike4 {
    function decimals() external view returns (uint);
    function balanceOf(address) external returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

contract GemBag {
    address  public ada;
    address  public lad;
    GemLike4 public gem;

    constructor(address lad_, address gem_) public {
        ada = msg.sender;
        lad = lad_;
        gem = GemLike4(gem_);
    }

    function exit(address usr, uint256 wad) external {
        require(msg.sender == ada || msg.sender == lad, "GemBag/invalid-caller");
        require(gem.transfer(usr, wad), "GemBag/failed-transfer");
    }
}

contract GemJoin4 is LibNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike4 public gem;
    uint     public dec;
    uint     public live;  // Access Flag

    mapping(address => address) public bags;

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike4(gem_);
        dec = gem.decimals();
    }

    function cage() external note auth {
        live = 0;
    }

    // -- admin --
    function make() external returns (address bag) {
        bag = make(msg.sender);
    }

    function make(address usr) public note returns (address bag) {
        require(bags[usr] == address(0), "GemJoin4/bag-already-exists");

        bag = address(new GemBag(address(usr), address(gem)));
        bags[usr] = bag;
    }

    // -- gems --
    function join(address urn, uint256 wad) external note {
        require(live == 1, "GemJoin4/not-live");
        require(int256(wad) >= 0, "GemJoin4/negative-amount");

        GemBag(bags[msg.sender]).exit(address(this), wad);
        vat.slip(ilk, urn, int256(wad));
    }

    function exit(address usr, uint256 wad) external note {
        require(int256(wad) >= 0, "GemJoin4/negative-amount");

        vat.slip(ilk, msg.sender, -int256(wad));
        require(gem.transfer(usr, wad), "GemJoin4/failed-transfer");
    }
}

// GemJoin5
// For a token that has a lower precision than 18 and it has decimals (like USDC)

interface GemLike5 {
    function decimals() external view returns (uint8);
    function transfer(address,uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
}

contract GemJoin5 is LibNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike5 public gem;
    uint     public dec;
    uint     public live;  // Access Flag

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        gem = GemLike5(gem_);
        dec = gem.decimals();
        require(dec < 18, "GemJoin5/decimals-18-or-higher");
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
    }

    function cage() external note auth {
        live = 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "GemJoin5/overflow");
    }

    function join(address urn, uint wad) public note {
        require(live == 1, "GemJoin5/not-live");
        uint wad18 = mul(wad, 10 ** (18 - dec));
        require(int(wad18) >= 0, "GemJoin5/overflow");
        vat.slip(ilk, urn, int(wad18));
        require(gem.transferFrom(msg.sender, address(this), wad), "GemJoin5/failed-transfer");
    }

    function exit(address guy, uint wad) public note {
        uint wad18 = mul(wad, 10 ** (18 - dec));
        require(int(wad18) >= 0, "GemJoin5/overflow");
        vat.slip(ilk, msg.sender, -int(wad18));
        require(gem.transfer(guy, wad), "GemJoin5/failed-transfer");
    }
}

// GemJoin6
// For a token with a proxy and implementation contract (like tUSD)
//  If the implementation behind the proxy is changed, this prevents joins
//   and exits until the implementation is reviewed and approved by governance.

interface GemLike6 {
    function decimals() external view returns (uint);
    function balanceOf(address) external returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
    function implementation() external view returns (address);
}

contract GemJoin6 is LibNote {
    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "GemJoin6/not-authorized");
        _;
    }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike6 public gem;
    uint     public dec;
    uint     public live;  // Access Flag

    mapping (address => uint256) public implementations;

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike6(gem_);
        setImplementation(gem.implementation(), 1);
        dec = gem.decimals();
    }
    function cage() external note auth {
        live = 0;
    }
    function setImplementation(address implementation, uint256 permitted) public auth note {
        implementations[implementation] = permitted;  // 1 live, 0 disable
    }
    function join(address usr, uint wad) external note {
        require(live == 1, "GemJoin6/not-live");
        require(int(wad) >= 0, "GemJoin6/overflow");
        require(implementations[gem.implementation()] == 1, "GemJoin6/implementation-invalid");
        vat.slip(ilk, usr, int(wad));
        require(gem.transferFrom(msg.sender, address(this), wad), "GemJoin6/failed-transfer");
    }
    function exit(address usr, uint wad) external note {
        require(wad <= 2 ** 255, "GemJoin6/overflow");
        require(implementations[gem.implementation()] == 1, "GemJoin6/implementation-invalid");
        vat.slip(ilk, msg.sender, -int(wad));
        require(gem.transfer(usr, wad), "GemJoin6/failed-transfer");
    }
}

// AuthGemJoin
// For a token that needs restriction on the sources which are able to execute the join function (like SAI through Migration contract)

interface GemLike {
    function decimals() external view returns (uint);
    function transfer(address,uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
}

contract AuthGemJoin is LibNote {
    VatLike public vat;
    bytes32 public ilk;
    GemLike public gem;
    uint    public dec;
    uint    public live;  // Access Flag

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1, "AuthGemJoin/non-authed"); _; }

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike(gem_);
        dec = gem.decimals();
    }

    function cage() external note auth {
        live = 0;
    }

    function join(address usr, uint wad) public auth note {
        require(live == 1, "AuthGemJoin/not-live");
        require(int(wad) >= 0, "AuthGemJoin/overflow");
        vat.slip(ilk, usr, int(wad));
        require(gem.transferFrom(msg.sender, address(this), wad), "AuthGemJoin/failed-transfer");
    }

    function exit(address usr, uint wad) public note {
        require(wad <= 2 ** 255, "AuthGemJoin/overflow");
        vat.slip(ilk, msg.sender, -int(wad));
        require(gem.transfer(usr, wad), "AuthGemJoin/failed-transfer");
    }
}

interface GemLike7 {
    // matches ERC20 spec
    function decimals() external view returns (uint);
    // matches ERC20 spec
    function transfer(address,uint) external;
    // matches ERC20 spec
    function transferFrom(address,address,uint) external;
    // USDT uses balanceOf() constant
    function balanceOf(address) external view returns (uint);
    // USDT uses allowance() constant
    function allowance(address,address) external view returns (uint);
    // doesn't match ERC20 spec
    function upgradedAddress() external view returns (address);
    // doesn't match ERC20 spec
    function deprecated() external view returns (bool);
    // doesn't match ERC20 spec
    function setImplementation(address,uint) external;
}

contract GemJoin7 is LibNote {
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    VatLike  public vat;
    bytes32  public ilk;
    GemLike7 public gem;
    uint     public dec;
    uint     public live; // Access flag

    mapping (address => uint256) public implementations;

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        gem = GemLike7(gem_);
        dec = gem.decimals();
        require(dec < 18, "GemJoin7/decimals-18-or-higher");
        wards[msg.sender] = 1;
        live = 1;
        vat = VatLike(vat_);
        ilk = ilk_;
        setImplementation(address(gem), 1);
    }

    function cage() external note auth {
        live = 0;
    }

    function setImplementation(address implementation, uint256 permitted) public auth note {
        implementations[implementation] = permitted; // 1 live, 0 distable
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "GemJoin7/overflow");
    }

    function join(address urn, uint wad) public note {
        require(live == 1, "GemJoin7/not-live");
        // mul does overflow check so require(wad < 2 ** 255) not needed
        uint wad18 = mul(wad, 10 ** (18 - dec));
        require(int(wad18) >= 0, "GemJoin7/overflow");

        // implementation check
        // tether uses a `deprecated` boolean; if deprecated is true, calls are forwarded to
        // an `upgradedAddress` address. so check if deprecated, if so, require upgradedAddress
        // to be approved by governance
        if (gem.deprecated()) {
            require(implementations[gem.upgradedAddress()] == 1, "GemJoin7/implementation-invalid");
        }

        vat.slip(ilk, urn, int(wad18));
        uint256 prevBalance = gem.balanceOf(msg.sender);

        require(prevBalance >= wad, "GemJoin7/no-funds");
        require(gem.allowance(msg.sender, address(this)) >= wad, "GemJoin7/no-allowance");

        (bool ok,) = address(gem).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), wad)
        );
        require(ok, "GemJoin7/failed-transfer");

        require(prevBalance - wad == gem.balanceOf(msg.sender), "GemJoin7/failed-transfer");
    }

    function exit(address guy, uint wad) public note {
        // mul does overflow check so require(wad < 2 ** 255) not needed
        uint wad18 = mul(wad, 10 ** (18 - dec));
        require(int(wad18) >= 0, "GemJoin5/overflow");

        // implementation check
        // tether uses a `deprecated` boolean; if deprecated is true, calls are forwarded to
        // an `upgradedAddress` address. so check if deprecated, if so, require upgradedAddress
        // to be approved by governance
        if (gem.deprecated()) {
            require(implementations[gem.upgradedAddress()] == 1, "GemJoin7/implementation-invalid");
        }

        vat.slip(ilk, msg.sender, -int(wad18));
        uint256 prevBalance = gem.balanceOf(address(this));
        require(prevBalance >= wad, "GemJoin7/no-funds");

        (bool ok,) = address(gem).call(
            abi.encodeWithSignature("transfer(address,uint256)", guy, wad)
        );
        require(ok, "GemJoin7/failed-transfer");

        require(prevBalance - wad == gem.balanceOf(address(this)), "GemJoin7/failed-transfer");
    }
}
