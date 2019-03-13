// not an ERC20
// no approve, no transferFrom, no allowance
pragma solidity >=0.5.0;

contract COL6Token {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Transfer(address indexed src, address indexed dst, uint wad);
    
    string  public  name = "COL6";
    string  public  symbol = "COL6";
    uint256  public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        require(_balances[msg.sender] >= wad, "ds-token-insufficient-balance");
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(msg.sender, dst, wad);

        return true;
    }
}