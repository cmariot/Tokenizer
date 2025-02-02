//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.20;


// ERC-20 Token Standard Interface :
// https://eips.ethereum.org/EIPS/eip-20


// Import IERC20 from OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import IERC20Metadata from OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Import ERC20 from OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Coin42 is IERC20, IERC20Metadata {

    // ********************************************************************* //

    /**
     * Name of the token : Coin42
     * Variable name is private, but we can access it through the public function name().
     * The setter is private, so the name can only be set in the constructor.
     */

    string private _name;

    function name() external view returns (string memory) {
        return _name;
    }

    // ********************************************************************* //

    /**
     * Symbol of the token : C42
     * Variable symbol is private, but we can access it through the public function symbol().
     * The setter is private, so the symbol can only be set in the constructor.
     */

    string private _symbol;

    function symbol() external view returns (string memory) {
        return _symbol;
    }


    // ********************************************************************* //

    /**
     * Decimals of the token : 18
     * Variable decimals is private, but we can access it through the public function decimals().
     * The setter is private, so the decimals can only be set in the constructor.
     */

    uint8 private immutable _decimals = 18;

    function decimals() external pure returns (uint8) {
        return _decimals;
    }


    // ********************************************************************* //


    /**
     * totalSupply : Returns the total token supply.
     */

    uint256 private _totalSupply;

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }


    // ********************************************************************* //

    /**
     * balanceOf: Returns the account balance of another account with address _owner.
     */

    mapping(address => uint256) private _balances;

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }


    // ********************************************************************* //

    /**
     * transfer: Transfers _value amount of tokens to address _to, and MUST
     * fire the Transfer event. The function SHOULD throw if the message
     * caller’s account balance does not have enough tokens to spend.
     * Note Transfers of 0 values MUST be treated as normal transfers and fire
     * the Transfer event.
     */

    // event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function transfer(address to, uint256 value) external returns (bool) {
        require(value <= _balances[msg.sender], 'Not enough tokens');
        require(to != address(0), "ERC20: transfer to the zero address");
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // ********************************************************************* //

    /**
     * transferFrom: Transfers _value amount of tokens from address _from to
     * address _to, and MUST fire the Transfer event.
     * The transferFrom method is used for a withdraw workflow, allowing
     * contracts to transfer tokens on your behalf.
     * This can be used for example to allow a contract to transfer tokens
     * on your behalf and/or to charge fees in sub-currencies.
     * The function SHOULD throw unless the _from account has deliberately
     * authorized the sender of the message via some mechanism.
     * Note Transfers of 0 values MUST be treated as normal transfers and fire
     * the Transfer event.
     */

    mapping(address => mapping (address => uint256)) private _allowed;

    // event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value <= _balances[from], "ERC20: transfer amount exceeds balance");
        require(value <= _allowed[from][msg.sender], "ERC20: transfer amount exceeds allowance");
        _balances[from] -= value;
        _balances[to] += value;
        _allowed[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // ********************************************************************* //

    /**
     * approve: Allows _spender to withdraw from your account multiple times,
     * up to the _value amount. If this function is called again it overwrites
     * the current allowance with _value.
     * NOTE: To prevent attack vectors, clients SHOULD make sure to create user
     * interfaces in such a way that they set the allowance first to 0 before
     * setting it to another value for the same spender.
     * THOUGH The contract itself shouldn’t enforce it, to allow backwards
     * compatibility with contracts deployed before
     */

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // ********************************************************************* //

    /**
     * allowance: Returns the amount which _spender is still allowed to withdraw from _owner.
     */

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowed[owner][spender];
    }


    // ********************************************************************* //

    /**
     * Constructor : Initializes contract with initial supply tokens to the creator of the contract.
     */

    address public owner;

    constructor() {
        _name = "Coin42";
        _symbol = "C42";
        _totalSupply = 1000000 * 10 ** uint256(_decimals);
        _balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }

    // ********************************************************************* //


}