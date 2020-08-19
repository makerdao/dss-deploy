pragma solidity >=0.5.12;

contract REP {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "REP";
    string  public  symbol = "REP";
    uint256  public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract ZRX {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "ZRX";
    string  public  symbol = "ZRX";
    uint256  public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract OMG {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "OMG";
    string  public  symbol = "OMG";
    uint256  public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);
    }

    function approve(address guy, uint wad) public {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);
    }
}

contract BAT {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "BAT";
    string  public  symbol = "BAT";
    uint256  public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract DGD {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "DGD";
    string  public  symbol = "DGD";
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract GNT {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "GNT";
    string  public  symbol = "GNT";
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
        require(_balances[msg.sender] >= wad, "insufficient-balance");
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(msg.sender, dst, wad);

        return true;
    }
}

contract USDC {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "USDC";
    string  public  symbol = "USDC";
    uint256  public  decimals = 6;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract WBTC {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "WBTC";
    string  public  symbol = "WBTC";
    uint256  public  decimals = 8;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract TUSD {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "TrueUSD";
    string  public  symbol = "TUSD";
    uint8   public  decimals = 18;
    address public  implementation;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
        setImplementation(address(this));
    }

    function setImplementation(address newImplementation) public {
        implementation = newImplementation;
    }

    function totalSupply() public view returns (uint256) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint256) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint256) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract KNC {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "KNC";
    string  public  symbol = "KNC";
    uint256  public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

contract MANA {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    string  public  name = "MANA";
    string  public  symbol = "MANA";
    uint8   public  decimals = 18;
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

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
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}
 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract USDT {
    using SafeMath for uint;

    string  public name = "Tether";
    string  public symbol = "USDT";
    uint    public decimals = 6;
    address public upgradedAddress;
    bool    public deprecated;

    mapping (address => mapping (address => uint)) public allowed;
    mapping (address => uint) public balances;

    uint public constant MAX_UINT = 2**256 - 1;

    address public owner;
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event Deprecate(address newAddress);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    constructor(uint _initialSupply) public {
        balances[msg.sender] = _initialSupply;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(msg.sender, owner, fee);
        }
        emit Transfer(msg.sender, _to, sendAmount);
    }

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        uint _allowance = allowed[_from][msg.sender];
        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // if (_value > _allowance) throw;
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(_from, owner, fee);
        }
        emit Transfer(_from, _to, sendAmount);
    }

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }
}

// pax implementation v2
contract PAXUSD {
    using SafeMath for uint256;
    bool private initialized = false;
    mapping(address => uint256) internal balances;
    uint256 internal totalSupply_;
    string public constant name = "Paxos Standard"; // solium-disable-line
    string public constant symbol = "PAX"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase
    mapping(address => mapping(address => uint256)) internal allowed;
    address public owner;
    bool public paused = false;
    address public assetProtectionRole;
    mapping(address => bool) internal frozen;
    address public supplyController;
    address public proposedOwner;
    address public betaDelegateWhitelister;
    mapping(address => bool) internal betaDelegateWhitelist;
    mapping(address => uint256) internal nextSeqs;
    string constant internal EIP191_HEADER = "\x19\x01";
    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(
        "EIP712Domain(string name,address verifyingContract)"
    );
    bytes32 constant internal EIP712_DELEGATED_TRANSFER_SCHEMA_HASH = keccak256(
        "BetaDelegatedTransfer(address to,uint256 value,uint256 fee,uint256 seq,uint256 deadline)"
    );
    bytes32 public EIP712_DOMAIN_HASH;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event OwnershipTransferProposed(
        address indexed currentOwner,
        address indexed proposedOwner
    );
    event OwnershipTransferDisregarded(
        address indexed oldProposedOwner
    );
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );
    event Pause();
    event Unpause();
    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);
    event AssetProtectionRoleSet (
        address indexed oldAssetProtectionRole,
        address indexed newAssetProtectionRole
    );
    event SupplyIncreased(address indexed to, uint256 value);
    event SupplyDecreased(address indexed from, uint256 value);
    event SupplyControllerSet(
        address indexed oldSupplyController,
        address indexed newSupplyController
    );

    function initialize() public {
        require(!initialized, "already initialized");
        owner = msg.sender;
        assetProtectionRole = address(0);
        totalSupply_ = 0;
        supplyController = msg.sender;
        initialized = true;
    }
    
    constructor() public {
        initialize();
        // pause();
        // Added in V2
        // initializeDomainSeparator();
    }

    // function initializeDomainSeparator() public {
    //     // hash the name context with the contract address
    //     EIP712_DOMAIN_HASH = keccak256(abi.encodePacked(// solium-disable-line
    //             EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
    //             keccak256(bytes(name)),
    //             bytes32(address(this))
    //         ));
    //     proposedOwner = address(0);
    // }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(_to != address(0), "cannot transfer to address zero");
        require(!frozen[_to] && !frozen[msg.sender], "address frozen");
        require(_value <= balances[msg.sender], "insufficient funds");
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _addr) public view returns (uint256) {
        return balances[_addr];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    whenNotPaused
    returns (bool)
    {
        require(_to != address(0), "cannot transfer to address zero");
        require(!frozen[_to] && !frozen[_from] && !frozen[msg.sender], "address frozen");
        require(_value <= balances[_from], "insufficient funds");
        require(_value <= allowed[_from][msg.sender], "insufficient allowance");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        require(!frozen[_spender] && !frozen[msg.sender], "address frozen");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    function proposeOwner(address _proposedOwner) public onlyOwner {
        require(_proposedOwner != address(0), "cannot transfer ownership to address zero");
        require(msg.sender != _proposedOwner, "caller already is owner");
        proposedOwner = _proposedOwner;
        emit OwnershipTransferProposed(owner, proposedOwner);
    }

    function disregardProposeOwner() public {
        require(msg.sender == proposedOwner || msg.sender == owner, "only proposedOwner or owner");
        require(proposedOwner != address(0), "can only disregard a proposed owner that was previously set");
        address _oldProposedOwner = proposedOwner;
        proposedOwner = address(0);
        emit OwnershipTransferDisregarded(_oldProposedOwner);
    }

    function claimOwnership() public {
        require(msg.sender == proposedOwner, "onlyProposedOwner");
        address _oldOwner = owner;
        owner = proposedOwner;
        proposedOwner = address(0);
        emit OwnershipTransferred(_oldOwner, owner);
    }

    function reclaimPAX() external onlyOwner {
        uint256 _balance = balances[address(this)];
        balances[address(this)] = 0;
        balances[owner] = balances[owner].add(_balance);
        emit Transfer(address(this), owner, _balance);
    }

    modifier whenNotPaused() {
        require(!paused, "whenNotPaused");
        _;
    }

    function pause() public onlyOwner {
        require(!paused, "already paused");
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner {
        require(paused, "already unpaused");
        paused = false;
        emit Unpause();
    }

    function setAssetProtectionRole(address _newAssetProtectionRole) public {
        require(msg.sender == assetProtectionRole || msg.sender == owner, "only assetProtectionRole or Owner");
        emit AssetProtectionRoleSet(assetProtectionRole, _newAssetProtectionRole);
        assetProtectionRole = _newAssetProtectionRole;
    }
    modifier onlyAssetProtectionRole() {
        require(msg.sender == assetProtectionRole, "onlyAssetProtectionRole");
        _;
    }

    function freeze(address _addr) public onlyAssetProtectionRole {
        require(!frozen[_addr], "address already frozen");
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    function unfreeze(address _addr) public onlyAssetProtectionRole {
        require(frozen[_addr], "address already unfrozen");
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    function wipeFrozenAddress(address _addr) public onlyAssetProtectionRole {
        require(frozen[_addr], "address is not frozen");
        uint256 _balance = balances[_addr];
        balances[_addr] = 0;
        totalSupply_ = totalSupply_.sub(_balance);
        emit FrozenAddressWiped(_addr);
        emit SupplyDecreased(_addr, _balance);
        emit Transfer(_addr, address(0), _balance);
    }

    function isFrozen(address _addr) public view returns (bool) {
        return frozen[_addr];
    }

    function setSupplyController(address _newSupplyController) public {
        require(msg.sender == supplyController || msg.sender == owner, "only SupplyController or Owner");
        require(_newSupplyController != address(0), "cannot set supply controller to address zero");
        emit SupplyControllerSet(supplyController, _newSupplyController);
        supplyController = _newSupplyController;
    }
    modifier onlySupplyController() {
        require(msg.sender == supplyController, "onlySupplyController");
        _;
    }

    function increaseSupply(uint256 _value) public returns (bool success) {
        totalSupply_ = totalSupply_.add(_value);
        balances[supplyController] = balances[supplyController].add(_value);
        emit SupplyIncreased(supplyController, _value);
        emit Transfer(address(0), supplyController, _value);
        return true;
    }

    function decreaseSupply(uint256 _value) public returns (bool success) {
        require(_value <= balances[supplyController], "not enough supply");
        balances[supplyController] = balances[supplyController].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit SupplyDecreased(supplyController, _value);
        emit Transfer(supplyController, address(0), _value);
        return true;
    }
}

