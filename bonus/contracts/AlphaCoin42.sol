//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.20;

contract AlphaCoin42 {

    string private constant _name = "AlphaCoin42";
    string private constant _symbol = "AC42";
    uint8 private constant  _decimals = 18;
    uint96 private constant _totalSupply = uint96(1_000_000 * 10 ** _decimals);

    // Mapping from token owner address to their balance.
    mapping(address => uint96) private _balances;
    // Mapping of locked tokens for each address (transactions waiting for approval)
    mapping(address => uint96) private _locked_balances;

    // Admin can add or remove signers / change the number of signers required
    address private _admin;

    // List of signers
    mapping(address => bool) private _signers;

    // Number of signers required to validate a transaction
    uint256 private _nbSignersRequired;

    struct Transaction {
        address from;
        address to;
        uint96  value;
        uint256 nbSigners;
        bool    executed;
        mapping (address => bool) signers;
    }

    uint256 public _transactions_id = 0;
    mapping(uint256 => Transaction) private _transactions;

    // Modifiers are used to check the privileges of the function caller

    modifier isAdminRequired {
        require(msg.sender == _admin, "ERC20: you are not the admin");
        _;
    }

    modifier isSignerRequired {
        require(isSigner(msg.sender), "ERC20: you are not a signer");
        _;
    }

    event Transfer(address indexed _from, address indexed _to, uint96 _value);

    constructor(
        address[] memory signers_,
        uint256 nbSignersRequired_
    ) {

        _admin = msg.sender;
        for (uint256 i = 0; i < signers_.length; i++) {
            addSigner(signers_[i]);
        }
        setNbSignerRequired(nbSignersRequired_);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure returns (uint96) {
        return _totalSupply;
    }

    function balanceOf(address owner_) external view returns (uint96) {
        return _balances[owner_];
    }

    function isSigner(address signer_) public view returns (bool) {
        return _signers[signer_];
    }

    function isAdmin(address admin_) public view returns (bool) {
        return admin_ == _admin;
    }

    function addSigner(address signer_) public isAdminRequired {
        require(signer_ != address(0), "ERC20: signer address is the zero address");
        require(!isSigner(signer_), "ERC20: signer address is already a signer");
        _signers[signer_] = true;
    }

    function removeSigner(address signer_) public isAdminRequired {
        require(isSigner(signer_), "ERC20: signer address is not a signer");
        _signers[signer_] = false;
    }

    function setNbSignerRequired(uint256 nbSignersRequired_) public isAdminRequired {
        require(nbSignersRequired_ > 0, "ERC20: number of signers required must be greater than 0");
        _nbSignersRequired = nbSignersRequired_;
    }

    event TransferSubmitted(uint256 transactions_id, address from, address to, uint96 value);
    event TransferCanceled(uint256 transactions_id);
    event TransferSigned(uint256 transactions_id, address signer);

    function submitTransfer(address to_, uint96 value_) public returns (uint256) {
        require(_balances[msg.sender] >= value_, "ERC20: transfer amount exceeds balance");
        require(to_ != address(0), "ERC20: transfer to the zero address");
        _balances[msg.sender] -= value_;
        _locked_balances[msg.sender] += value_;
        _transactions[_transactions_id].from = msg.sender;
        _transactions[_transactions_id].to = to_;
        _transactions[_transactions_id].value = value_;
        _transactions[_transactions_id].nbSigners = 0;
        _transactions[_transactions_id].executed = false;
        emit TransferSubmitted(_transactions_id, msg.sender, to_, value_);
        _transactions_id++;
        return _transactions_id;
    }

    function cancelTransfer(uint256 transactionId) public {
        require(transactionId < _transactions_id, "ERC20: transaction id does not exist");
        Transaction storage transaction = _transactions[transactionId];
        require(transaction.from == msg.sender, "ERC20: you are not the sender of the transaction");
        _locked_balances[msg.sender] -= transaction.value;
        _balances[msg.sender] += transaction.value;
        transaction.value = 0;
        transaction.executed = true;
        emit TransferCanceled(transactionId);
    }

    function signTransfer(uint256 transactionId) public isSignerRequired {
        require(transactionId < _transactions_id, "ERC20: transaction id does not exist");
        Transaction storage transaction = _transactions[transactionId];
        require(transaction.value > 0 && !transaction.executed, "ERC20: transaction has already been canceled");
        require(!transaction.signers[msg.sender], "ERC20: you have already signed the transaction");
        transaction.signers[msg.sender] = true;
        transaction.nbSigners++;
        emit TransferSigned(transactionId, msg.sender);
        if (transaction.nbSigners == _nbSignersRequired) {
            executeTransfer(transactionId);
        }
    }

    function executeTransfer(uint256 transactionId) private {
        Transaction storage transaction = _transactions[transactionId];
        require(!transaction.executed, "ERC20: transaction has already been executed");
        require(transaction.value > 0 && !transaction.executed, "ERC20: transaction has already been canceled");
        require(transaction.nbSigners == _nbSignersRequired, "ERC20: transaction has not been signed by enough signers");
        _locked_balances[transaction.from] -= transaction.value;
        _balances[transaction.to] += transaction.value;
        emit Transfer(transaction.from, transaction.to, transaction.value);
        transaction.executed = true;
        transaction.value = 0;
    }

}