pragma solidity 0.6.4;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Rset is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping (address => bool) private _feeWhiteList;
    mapping (address => bool) private _lockWhiteList;
    bool locked = true;
    uint256 public basePercent = 100; // 1%

    constructor () public {
        _name = "Rset";
        _symbol = "RSET";
        _decimals = 18;
        uint256 amount = 100000000000000000000000000;
        _totalSupply = amount;
        _balances[_msgSender()] = amount;
        emit Transfer(address(0), _msgSender(), amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function addToWhitelist(address wallet) onlyOwner() external {
        _feeWhiteList[wallet] = true;
    }

    function removeFromWhitelist(address wallet) onlyOwner() external {
        _feeWhiteList[wallet] = false;
    }

    function addToLockWhitelist(address wallet) onlyOwner() external {
        _lockWhiteList[wallet] = true;
    }

    function removeFromLockWhitelist(address wallet) onlyOwner() external {
        _lockWhiteList[wallet] = false;
    }

    function release() onlyOwner external {
        locked = false;
    }

    function _transfer(address from, address to, uint256 value) private returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!locked || _lockWhiteList[to] || _lockWhiteList[from], "ERC20: Not release yet");

        if (_feeWhiteList[to] || _feeWhiteList[from]) {

            _balances[from] = _balances[from].sub(value, "ERC20: transfer amount exceeds balance");
            _balances[to] = _balances[to].add(value);
            emit Transfer(from, to, value);

        } else {

            _balances[from] = _balances[from].sub(value, "ERC20: transfer amount exceeds balance");

            uint256 tokensToBurn = findOnePercent(value);
            uint256 tokensToTransfer = value.sub(tokensToBurn);

            _balances[to] = _balances[to].add(tokensToTransfer);
            _totalSupply = _totalSupply.sub(tokensToBurn);

            emit Transfer(from, to, tokensToTransfer);
            emit Transfer(from, address(0), tokensToBurn);
        }
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "RSET: approve from the zero address");
        require(spender != address(0), "RSET: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function findOnePercent(uint256 value) public view returns (uint256)  {
        return value.mul(basePercent).div(10000);
    }

}
