//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.28;


// ERC-20 Token Standard Interface :
// https://eips.ethereum.org/EIPS/eip-20

// Import the Niel42 contract interface
import "./Niel42.sol";

contract Niel42MultiSig is Niel42 {

    // Name of the token
    string private constant _name = "Niel42MultiSig";
    // Symbol of the token
    string private constant _symbol = "N42MS";

    /*
    Returns the name of the token - e.g. "Niel42MultiSig".
    */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /*
    Returns the symbol of the token. e.g. "N42MS".
    */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /*
    Mapping des admins
    */
    address private _owner;
    mapping(address => bool) private _admins;
    address[] private _adminList;

    /*
    Number of proposals to validate
    */
    uint256 private _proposalsToValidate;

    /*
    Modifiers
    */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }
    modifier onlyAdmin() {
        require(_admins[msg.sender] || msg.sender == _owner, "Caller is not an admin or owner");
        _;
    }


    /*
    Add an admin
    */
    function addAdmin(address admin) public onlyOwner {
        require(admin != address(0), "Invalid admin address");
        require(!_admins[admin], "Admin already exists");
        _admins[admin] = true;
        _adminList.push(admin);
        emit AdminAdded(admin);
    }

    /*
    Remove an admin
    */
    function removeAdmin(address admin) public onlyOwner {
        require(admin != address(0), "Invalid admin address");
        require(admin != _owner, "Cannot remove the owner");
        require(_admins[admin], "Not an admin");
        require(_adminList.length > 1, "Cannot remove the last admin");
        _admins[admin] = false;
        // Remove from array
        for (uint256 i = 0; i < _adminList.length; i++) {
            if (_adminList[i] == admin) {
                _adminList[i] = _adminList[_adminList.length - 1];
                _adminList.pop();
                break;
            }
        }
        emit AdminRemoved(admin);
    }

    /*
    Set the number of proposals to validate
    */
    function setProposalsToValidate(uint256 proposalsToValidate_) public onlyAdmin {
        require(proposalsToValidate_ > 0, "Proposals to validate must be greater than zero");
        _proposalsToValidate = proposalsToValidate_;
    }

    /*
    Constructor
    */
    constructor(
        address[] memory admins,
        uint256 proposalsToValidate_
    ) Niel42() {

        require(admins.length > 0, "At least one admin is required");
        require(proposalsToValidate_ > 0, "Proposals to validate must be greater than zero");
        require(msg.sender != address(0), "Invalid owner address");

        _owner = msg.sender;

        // Set the initial admins
        for (uint256 i = 0; i < admins.length; i++) {
            address admin = admins[i];
            require(admin != address(0), "Invalid admin address");
            require(!_admins[admin], "Admin already exists");
            _admins[admin] = true;
            _adminList.push(admin);
        }

        // Set the number of proposals to validate
        _proposalsToValidate = proposalsToValidate_;

    }

    /*
    Returns the number of proposals to validate.
    */
    function proposalsToValidate() public view returns (uint256) {
        return _proposalsToValidate;
    }

    /*
    Enum to represent the different states of a proposal
    */
    enum ProposalState {
        Pending,
        Approved,
        Cancelled
    }

    /*
    Enum to represent the different types of proposals
    */
    enum ProposalType {
        Mint,
        Burn
    }

    /*
    Structure to hold proposal data
    */

    struct Proposal {
        address proposer;
        ProposalType proposalType;
        address target;
        uint256 amount;
        ProposalState state;
        uint256 approvals;
        mapping(address => bool) approvedBy;
    }

    /*
    Mapping to hold proposals
    */
    mapping(uint256 => Proposal) private _proposals;

    /*
    Counter for proposal IDs
    */
    uint256 private _proposalIdCounter;

    /*
    Function to create a proposal
    */
    function createProposal(
        ProposalType proposalType,
        address target,
        uint256 amount
    ) public onlyAdmin returns (uint256) {
        require(target != address(0), "Invalid target address");
        require(amount > 0, "Amount must be greater than zero");
        uint256 proposalId = _proposalIdCounter;
        Proposal storage proposal = _proposals[proposalId];
        proposal.proposer = msg.sender;
        proposal.proposalType = proposalType;
        proposal.target = target;
        proposal.amount = amount;
        proposal.state = ProposalState.Pending;
        proposal.approvals = 0;
        _proposalIdCounter++;
        emit ProposalCreated(proposalId, msg.sender, proposalType, target, amount);
        return proposalId;
    }

    /*
    Function to approve a proposal
    */
    function approveProposal(uint256 proposalId) public onlyAdmin {
        require(proposalId < _proposalIdCounter, "Invalid proposal ID");
        Proposal storage proposal = _proposals[proposalId];
        require(proposal.state == ProposalState.Pending, "Proposal is not pending");
        require(!proposal.approvedBy[msg.sender], "Already approved by this admin");
        proposal.approvedBy[msg.sender] = true;
        proposal.approvals++;
        emit ProposalApproved(proposalId, msg.sender);
        if (proposal.approvals >= _proposalsToValidate) {
            proposal.state = ProposalState.Approved;
            if (proposal.proposalType == ProposalType.Mint) {
                _mint(proposal.target, proposal.amount);
            } else if (proposal.proposalType == ProposalType.Burn) {
                _burn(proposal.target, proposal.amount);
            }
            emit ProposalExecuted(proposalId, proposal.proposalType, proposal.target, proposal.amount);
        }
    }

    /*
    Function to cancel a proposal
    */
    function cancelProposal(uint256 proposalId) public onlyAdmin {
        require(proposalId < _proposalIdCounter, "Invalid proposal ID");
        Proposal storage proposal = _proposals[proposalId];
        require(proposal.state == ProposalState.Pending, "Proposal is not pending");
        require(proposal.proposer == msg.sender || isAdmin(msg.sender), "Only proposer or admin can cancel");
        proposal.state = ProposalState.Cancelled;
        emit ProposalCancelled(proposalId, msg.sender);
    }

    /*
    Function to get proposal details
    */
    function getProposal(uint256 proposalId) public view returns (
        address proposer,
        ProposalType proposalType,
        address target,
        uint256 amount,
        ProposalState state,
        uint256 approvals
    ) {
        require(proposalId < _proposalIdCounter, "Invalid proposal ID");
        Proposal storage proposal = _proposals[proposalId];
        return (
            proposal.proposer,
            proposal.proposalType,
            proposal.target,
            proposal.amount,
            proposal.state,
            proposal.approvals
        );
    }

    /*
    Function to get the number of proposals
    */

    function getProposalCount() public view returns (uint256) {
        return _proposalIdCounter;
    }

    /*
    Function to check if an address is an admin
    */

    function isAdmin(address admin) public view returns (bool) {
        return _admins[admin];
    }

    /*
    Helper to get who approved a proposal (returns array of addresses)
    */
    function getProposalApprovers(uint256 proposalId, address[] memory adminList) public view returns (address[] memory) {
        require(proposalId < _proposalIdCounter, "Invalid proposal ID");
        Proposal storage proposal = _proposals[proposalId];
        uint256 count = 0;
        for (uint256 i = 0; i < adminList.length; i++) {
            if (proposal.approvedBy[adminList[i]]) {
                count++;
            }
        }
        address[] memory approvers = new address[](count);
        uint256 idx = 0;
        for (uint256 i = 0; i < adminList.length; i++) {
            if (proposal.approvedBy[adminList[i]]) {
                approvers[idx++] = adminList[i];
            }
        }
        return approvers;
    }

    /*
    Mint function to create new tokens
    */
    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "Mint to the zero address");
        require(amount > 0, "Mint amount must be greater than zero");

        // Update the total supply
        _totalSupply += amount;

        // Update the account balance
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    /*
    Burn function to destroy tokens
    */
    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "Burn from the zero address");
        require(amount > 0, "Burn amount must be greater than zero");
        require(_balances[account] >= amount, "Burn amount exceeds balance");
        require(_totalSupply >= amount, "Burn amount exceeds total supply");

        // Update the total supply
        _totalSupply -= amount;

        // Update the account balance
        _balances[account] -= amount;

        emit Transfer(account, address(0), amount);
    }

    /*
    Events for multisig tracking
    */
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, ProposalType proposalType, address indexed target, uint256 amount);
    event ProposalApproved(uint256 indexed proposalId, address indexed admin);
    event ProposalExecuted(uint256 indexed proposalId, ProposalType proposalType, address indexed target, uint256 amount);
    event AdminRemoved(address indexed admin);
    event AdminAdded(address indexed admin);
    event ProposalCancelled(uint256 indexed proposalId, address indexed admin);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /*
    Function to get the list of admins
    */
    function getAdmins() public view returns (address[] memory) {
        return _adminList;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        require(newOwner != _owner, "New owner is already the owner");
        address previousOwner = _owner;
        _owner = newOwner;
        if (!_admins[newOwner]) {
            _admins[newOwner] = true;
            _adminList.push(newOwner);
            emit AdminAdded(newOwner);
        }
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

}