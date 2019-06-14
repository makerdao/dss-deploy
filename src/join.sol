/// adapters.sol -- Non-standard token adapters

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

pragma solidity >=0.5.0;

import "ds-note/note.sol";

contract Gem2TokenLike {
    function transfer(address,uint) public;
    function transferFrom(address,address,uint) public;
    function balanceOf(address) public view returns (uint);
    function allowance(address,address) public view returns (uint);
}

contract Gem3TokenLike {
    function decimals() public returns (uint);
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
}

contract VatLike {
    function slip(bytes32,address,int) public;
}

/*
    Here we provide *adapters* to connect the Vat to arbitrary external
    token implementations, creating a bounded context for the Vat. The
    adapters here are provided as working examples:

        - `GemJoin2`: For a token that does not return a bool on transfer or transferFrom (like Token3)
        - `GemJoin3`: For a token that has a lower precision than 18 (like Token5)

    In practice, adapter implementations will be varied and specific to
    individual collateral types, accounting for different transfer
    semantics and token standards.

    Adapters need to implement two basic methods:

      - `join`: enter collateral into the system
      - `exit`: remove collateral from the system

*/

// This is one way of doing it. Check the balances before and after calling a transfer
contract GemJoin2 is DSNote {
    VatLike public vat;
    bytes32 public ilk;
    Gem2TokenLike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = Gem2TokenLike(gem_);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function join(address urn, uint wad) public note {
        require(wad <= 2 ** 255, "");
        vat.slip(ilk, urn, int(wad));
        uint256 prevBalance = gem.balanceOf(msg.sender);

        require(prevBalance >= wad, "");
        require(gem.allowance(msg.sender, address(this)) >= wad, "");

        (bool ok, bytes memory data) = address(gem).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), wad)
        );
        ok;
        data;

        require(prevBalance - wad == gem.balanceOf(msg.sender), "");
    }
    function exit(address guy, uint wad) public note {
        require(wad <= 2 ** 255, "");
        vat.slip(ilk, msg.sender, -int(wad));
        uint256 prevBalance = gem.balanceOf(address(this));

        require(prevBalance >= wad, "");

        (bool ok,) = address(gem).call(
            abi.encodeWithSignature("transfer(address,uint256)", guy, wad)
        );
        require(ok, "");

        require(prevBalance - wad == gem.balanceOf(address(this)), "");
    }
}

contract GemJoin3 is DSNote {
    VatLike public vat;
    bytes32 public ilk;
    Gem3TokenLike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = Gem3TokenLike(gem_);
        require(gem.decimals() < 18, "");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function join(address urn, uint wad) public note {
        uint wad18 = mul(wad, 10 ** (18 - gem.decimals()));
        require(wad18 <= 2 ** 255, "");
        vat.slip(ilk, urn, int(wad18));
        require(gem.transferFrom(msg.sender, address(this), wad), "");
    }
    function exit(address guy, uint wad) public note {
        uint wad18 = mul(wad, 10 ** (18 - gem.decimals()));
        require(wad18 <= 2 ** 255, "");
        vat.slip(ilk, msg.sender, -int(wad18));
        require(gem.transfer(guy, wad), "");
    }
}
