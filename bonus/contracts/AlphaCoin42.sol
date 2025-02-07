//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.20;


// ERC-20 Token Standard Interface :
// https://eips.ethereum.org/EIPS/eip-20


// Console log for debugging
import "hardhat/console.sol";

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

    // Mapping from token owner address to their balance.
    mapping(address => uint96) private _balances;
    // Mapping of locked tokens for each address (transactions waiting for approval)
    mapping(address => uint96) private _locked_balances;

    // Admin
    address private _admin;

    // Signers
    mapping(address => bool) private _signers;

    // Number of signers required to validate a transaction
    uint256 private _nbSignersRequired;

    uint256 public _transactions_id = 0;

    struct Transaction {
        address from;
        address to;
        uint96 value;
        uint256 nbSigners;
        address[] signers;
        bool executed;
    }

    Transaction[] private _transactions;

    // Modifiers

    modifier isAdminRequired {
        require(msg.sender == _admin, "ERC20: you are not the admin");
        _;
    }

    modifier isSignerRequired {
        require(isSigner(msg.sender), "ERC20: you are not a signer");
        _;
    }



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
    constructor(address[] memory signers_, uint256 nbSignersRequired_) {

        _admin = msg.sender;
        for (uint256 i = 0; i < signers_.length; i++) {
            addSigner(signers_[i]);
        }
        setNbSignerRequired(nbSignersRequired_);

        _balances[msg.sender] = _totalSupply;

        _transactions_id = 0;

        emit Transfer(address(0), msg.sender, _totalSupply);

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


    event TransferSubmitted(uint256 _transactions_id);

    function submitTransfer(address to_, uint96 value_) public returns (uint256) {

        require(_balances[msg.sender] >= value_, "ERC20: transfer amount exceeds balance");
        require(to_ != address(0), "ERC20: transfer to the zero address");

        _balances[msg.sender] -= value_;
        _locked_balances[msg.sender] += value_;

        Transaction memory transaction = Transaction({
            from : msg.sender,
            to : to_,
            value : value_,
            nbSigners : 0,
            signers : new address[](0),
            executed : false
        });

        _transactions.push(transaction);

        _transactions_id = _transactions_id + 1;

        emit TransferSubmitted(_transactions_id);

        return _transactions_id;
    }


    function cancelTransfer(uint256 transactionId) public {

        require(transactionId < _transactions_id, "ERC20: transaction id does not exist");

        Transaction storage transaction = _transactions[transactionId];

        require(transaction.from == msg.sender, "ERC20: you are not the sender of the transaction");

        _balances[msg.sender] += transaction.value;
        _locked_balances[msg.sender] -= transaction.value;

        transaction.value = 0;
        transaction.executed = true;
    }

    function isSignerInTransaction(Transaction memory transaction, address signer) private pure returns (bool) {
        for (uint256 i = 0; i < transaction.signers.length; i++) {
            if (transaction.signers[i] == signer) {
                return true;
            }
        }
        return false;
    }

    function signTransfer(uint256 transactionId) public isSignerRequired {

        require(transactionId < _transactions_id, "ERC20: transaction id does not exist");

        Transaction storage transaction = _transactions[transactionId];

        require(transaction.value > 0 && !transaction.executed, "ERC20: transaction has already been canceled");

        require(!isSignerInTransaction(transaction, msg.sender), "ERC20: you have already signed the transaction");

        transaction.signers.push(msg.sender);
        transaction.nbSigners++;

        if (transaction.nbSigners == _nbSignersRequired) {
            executeTransfer(transactionId);
        }
    }

    function executeTransfer(uint256 transactionId) private {

        Transaction storage transaction = _transactions[transactionId];

        require(transaction.value > 0 && !transaction.executed, "ERC20: transaction has already been canceled");

        require(transaction.nbSigners == _nbSignersRequired, "ERC20: transaction has not been signed by enough signers");

        console.log("Transaction executed");

        _locked_balances[msg.sender] -= transaction.value;
        _balances[transaction.to] += transaction.value;

        transaction.executed = true;

        emit Transfer(transaction.from, transaction.to, transaction.value);

    }




}