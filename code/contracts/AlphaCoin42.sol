//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.20;


// ERC-20 Token Standard Interface :
// https://eips.ethereum.org/EIPS/eip-20


contract AlphaCoin42 {

    // State variables

    // Name of the token
    string private constant _name = "AlphaCoin42";
    // Symbol of the token
    string private constant _symbol = "AC42";
    // Decimals of the token
    uint8 private constant _decimals = 18;
    // Total supply of the token
    uint96 private constant _totalSupply = uint96(1_000_000 * 10 ** _decimals);

    // Signers of the contract
    address[] private _signers;
    uint8 private _nbSignersRequired;
    mapping(address => bool) private _isSigner;

    // Mapping from token owner address to their balance.
    mapping(address => uint96) private _balances;
    // Imbricated mapping from token owner address to spender address to the
    // amount of tokens they are allowed to transfer.
    mapping(address => mapping(address => uint96)) private _allowances;

    // Transaction structure
    struct Transaction {
        address from;
        address to;
        uint96 value;
        mapping(address => bool) signers;
        uint8 nbSigners;
        bool executed;
    }
    // Array of transactions
    uint256 private _transactionId = 0;
    Transaction[] private _transactions;

    // Events

    /*
    Transfer event
    MUST trigger when tokens are transferred, including zero value transfers.
    A token contract which creates new tokens SHOULD trigger a Transfer event
    with the _from address set to 0x0 when tokens are created.
    */
    event Transfer(address indexed _from, address indexed _to, uint96 _value);

    /*
    Approval event
    MUST trigger on any successful call to approve(address _spender, uint96 _value).
    */
    event Approval(address indexed _owner, address indexed _spender, uint96 _value);

    /*
    Contract constructor
    */
    constructor(address[] memory signers_, uint8 nbSignersRequired_) {

        require(signers_.length >= nbSignersRequired_ && nbSignersRequired_ > 0,
                "AlphaCoin42: not enough signers");

        // Assign the signers to the contract
        _signers = signers_;
        _nbSignersRequired = nbSignersRequired_;
        for (uint8 i = 0; i < signers_.length; i++) {
            require(!_isSigner[signers_[i]], "AlphaCoin42: signer already added");
            require(signers_[i] != address(0), "AlphaCoin42: signer is the zero address");
            _isSigner[signers_[i]] = true;
            _balances[signers_[i]] = _totalSupply / uint96(signers_.length);
        }

        // Trigger the Transfer event
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /*
    Returns the name of the token - e.g. "AlphaCoin42".
    */
    function name() public pure returns (string memory) {
        return _name;
    }

    /*
    Returns the symbol of the token. e.g. "AC42".
    */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /*
    Returns the number of decimals the token uses.
    For example, suppose I'm creating a token called "dollars,"
    and I want people to be able to transfer an amount like $1.25.
    To support that, I'll use a decimals value of 2.
    */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /*
    Returns the total token supply.
    The total token supply is the number of tokens available to the public.
    */
    function totalSupply() public pure returns (uint96) {
        return _totalSupply;
    }

    /*
    balanceOf function returns the balance of the given address.
    */
    function balanceOf(address owner_) external view returns (uint96) {
        return _balances[owner_];
    }

    /*
    isSigner function returns true if the given address is a signer.
    */
    function isSigner(address account_) public view returns (bool) {
        return _isSigner[account_];
    }

    /*
    nbSignersRequired function returns the number of signers required to validate a transaction.
    */
   function nbSignersRequired() public view returns (uint8) {
       return _nbSignersRequired;
    }

    /*
    submitTransaction function submits a transaction to the contract.
    */

    event TransactionSubmited(uint256 transactionId, address from, address to, uint96 value);

    function submitTransaction(adress to_, uint96 value_) public returns (bool) {
        require(_balances[msg.sender] >= value_, "AlphaCoin42: not enough balance");
        require(to_ != address(0), "AlphaCoin42: transfer to the zero address");
        require(value_ > 0, "AlphaCoin42: transfer value must be greater than zero");
        Transaction memory transaction = Transaction({
            from: msg.sender,
            to: to_,
            value: value_,
            nbSigners: 0,
            executed: false
        });
        _transactions.push(transaction);
        emit TransactionSubmited(_transactionId, msg.sender, to_, value_);
        _transactionId++;
        return true;
    }

    function signTransaction(uint256 transactionId) public returns (bool) {
        require(_isSigner[msg.sender], "AlphaCoin42: only signers can sign a transaction");
        require(transactionId < _transactionId, "AlphaCoin42: transaction does not exist");
        Transaction storage transaction = _transactions[transactionId];
        require(!transaction.signers[msg.sender], "AlphaCoin42: signer already signed the transaction");
        transaction.signers[msg.sender] = true;
        transaction.nbSigners++;

        if (transaction.nbSigners == _nbSignersRequired) {
            executeTransaction(transaction);
        }
        return true;
    }


    function executeTransaction(Transaction transaction) private returns (bool) {
        require(_balances[transaction.from] >= transaction.value, "AlphaCoin42: not enough balance");
        _balances[transaction.from] -= transaction.value;
        _balances[transaction.to] += transaction.value;
        emit Transfer(transaction.from, transaction.to, transaction.value);
        return true;
    }


    /*
    Transfer function transfers tokens from the sender's address to the recipient's address.
    */
    function transfer(address to_, uint96 value_) public returns (bool success) {
        require(to_ != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= value_, "ERC20: transfer amount exceeds balance");
        _balances[msg.sender] -= value_;
        _balances[to_] += value_;
        emit Transfer(msg.sender, to_, value_);
        return true;
    }

    /*
    allowance
    Returns the amount which spender_ is still allowed to withdraw from owner_.
    */
    function allowance(address owner_, address spender_) public view returns (uint96) {
        return _allowances[owner_][spender_];
    }

    /*
    approve
    Allows _spender to withdraw from your account multiple times, up to the
    _value amount. If this function is called again it overwrites the
    current allowance with _value.
    NOTE: To prevent attack vectors like the one described here and discussed
    here, clients SHOULD make sure to create user interfaces in such a way
    that they set the allowance first to 0 before setting it to another value
    for the same spender. THOUGH The contract itself shouldn’t enforce it,
    to allow backwards compatibility with contracts deployed before
    */
    function approve(address spender_, uint96 value_) public returns (bool success) {
        require(spender_ != address(0), "ERC20: approve to the zero address");
        require(_allowances[msg.sender][spender_] == 0 || value_ == 0,
                "ERC20: must first set allowance to zero");
        _allowances[msg.sender][spender_] = value_;
        emit Approval(msg.sender, spender_, value_);
        return true;
    }

    /*
    Pour eviter deux calls à approve, on peut utiliser les fonctions
    increaseAllowance et decreaseAllowance
    */
    function increaseAllowance(address spender_, uint96 addedValue) public returns (bool) {
        uint96 newAllowance = _allowances[msg.sender][spender_] + addedValue;
        _allowances[msg.sender][spender_] = newAllowance;
        emit Approval(msg.sender, spender_, newAllowance);
        return true;
    }

    function decreaseAllowance(address spender_, uint96 subtractedValue) public returns (bool) {
        uint96 currentAllowance = _allowances[msg.sender][spender_];
        require(currentAllowance >= subtractedValue,
                "ERC20: decreased allowance below zero");
        uint96 newAllowance = currentAllowance - subtractedValue;
        _allowances[msg.sender][spender_] = newAllowance;
        emit Approval(msg.sender, spender_, newAllowance);
        return true;
    }

    /*
    transferFrom:
    Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
    The transferFrom method is used for a withdraw workflow, allowing
    contracts to transfer tokens on your behalf. This can be used for
    example to allow a contract to transfer tokens on your behalf and/or to
    charge fees in sub-currencies.
    The function SHOULD throw unless the _from account has deliberately
    authorized the sender of the message via some mechanism.
    Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
    */
    function transferFrom(address from_, address to_, uint96 value_) public returns (bool success) {
        require(value_ <= _balances[from_], "ERC20: transfer amount exceeds balance");
        require(value_ <= _allowances[from_][msg.sender], "ERC20: insufficient allowance");
        require(to_ != address(0), "ERC20: transfer to the zero address");

        _balances[from_] -= value_;
        _balances[to_] += value_;
        _allowances[from_][msg.sender] -= value_;

        emit Transfer(from_, to_, value_);

        return true;
    }

}
