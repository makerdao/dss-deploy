/// join.sol -- Basic token adapters

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

pragma solidity ^0.4.20;

contract GemLike {
    function move(address,address,uint) public;  // i.e. transferFrom
}

contract Fluxing {
    function slip(bytes32,address,int) public;
}

contract AdapterETH {
    Fluxing public vat;
    bytes32 public ilk;
    GemLike public gem;
    constructor(address vat_, bytes32 ilk_) public {
        vat = Fluxing(vat_);
        ilk = ilk_;
    }
    function join() payable public {
        require(msg.value >= 0);
        vat.slip(ilk, msg.sender, int(msg.value));
    }
    function exit(uint wad) public {
        require(int(wad) >= 0);
        vat.slip(ilk, msg.sender, -int(wad));
        address(msg.sender).transfer(wad);
    }
}
