//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.20;


// ERC-20 Token Standard Interface :
// https://eips.ethereum.org/EIPS/eip-20


contract AlphaCoin42 {


    // State variables

    // Name of the token
    string private _name;
    // Symbol of the token
    string private _symbol;
    // Decimals of the token
    uint8 private _decimals = 18;
    // Total supply of the token
    uint256 private _totalSupply;



    // Events

    // Transfer event
    // MUST trigger when tokens are transferred, including zero value transfers.
    // A token contract which creates new tokens SHOULD trigger a Transfer event
    // with the _from address set to 0x0 when tokens are created.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    // Constructor of the contract
    constructor()
    {
        _name = "AlphaCoin42";
        _symbol = "AC42";
        _totalSupply = 1_000_000 * 10 ** uint256(_decimals);

        // Assign the total supply to the contract creator
        _balances[msg.sender] = _totalSupply;

        // Trigger the Transfer event
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    // Returns the name of the token - e.g. "AlphaCoin42".
    function name() public view returns (string memory)
    {
        return _name;
    }

    // Returns the symbol of the token. e.g. "AC42".
    function symbol() public view returns (string memory)
    {
        return _symbol;
    }

    // Returns the number of decimals the token uses.
    // For example, suppose I'm creating a token called "dollars,"
    // and I want people to be able to transfer an amount like $1.25.
    // To support that, I'll use a decimals value of 2.
    function decimals() public view returns (uint8)
    {
        return _decimals;
    }

    // Returns the total token supply.
    // The total token supply is the number of tokens available to the public.
    function totalSupply() public view returns (uint256)
    {
        return _totalSupply;
    }


    // Mapping from token owner address to their balance.
    mapping(address => uint256) private _balances;

    // balanceOf function returns the balance of the given address.
    function balanceOf(address owner_) public view returns (uint256 balance)
    {
        return _balances[owner_];
    }


    // Transfer function transfers tokens from the sender's address to the recipient's address.
    function transfer(address to_, uint256 value_) public returns (bool success)
    {
        require(to_ != address(0), "ERC20: transfer to the zero address");
        require(value_ <= totalSupply(), "ERC20: transfer amount exceeds total supply");
        require(_balances[msg.sender] >= value_, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= value_;
        _balances[to_] += value_;

        emit Transfer(msg.sender, to_, value_);

        return true;
    }

    /**
     * transferFrom:
     *
     * Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
     *
     * The transferFrom method is used for a withdraw workflow, allowing
     * contracts to transfer tokens on your behalf. This can be used for
     * example to allow a contract to transfer tokens on your behalf and/or to
     * charge fees in sub-currencies.
     * The function SHOULD throw unless the _from account has deliberately
     * authorized the sender of the message via some mechanism.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     */
    function transferFrom(address from_, address to_, uint256 value_) public returns (bool success)
    {
        // require(from_ != address(0), "ERC20: transfer from the zero address");
        // require(to_ != address(0), "ERC20: transfer to the zero address");
        // require(value_ <= totalSupply(), "ERC20: transfer amount exceeds total supply");
        // require(_balances[from_] >= value_, "ERC20: transfer amount exceeds balance");

        // require(from_ == msg.sender, "ERC20: transferFrom caller is not the owner");

        // _balances[from_] -= value_;
        // _balances[to_] += value_;

        // emit Transfer(from_, to_, value_);

        // return true;
    }


    // approve

    // allowance

}