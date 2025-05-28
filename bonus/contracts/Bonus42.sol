//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.28;


// ERC-20 Token Standard Interface :
// https://eips.ethereum.org/EIPS/eip-20

// Import the Niel42 contract interface
import "./Niel42.sol";

contract Niel42Bonus is Niel42 {

    // Name of the token
    string private constant _name = "Niel42Bonus";
    // Symbol of the token
    string private constant _symbol = "N42B";

    /*
    Returns the name of the token - e.g. "Niel42Bonus".
    */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /*
    Returns the symbol of the token. e.g. "N42B".
    */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /*
    Mapping des admins
    */
    mapping(address => bool) private _admins;

    /*
    Modifiers
    */
    modifier onlyAdmin() {
        require(_admins[msg.sender], "Caller is not an admin");
        _;
    }

    /*
    Add an admin
    */
    function addAdmin(address admin) public onlyAdmin {
        require(admin != address(0), "Invalid admin address");
        _admins[admin] = true;
    }

    /*
    Remove an admin
    */
    function removeAdmin(address admin) public onlyAdmin {
        require(admin != address(0), "Invalid admin address");
        _admins[admin] = false;
    }

    /*
    Constructor
    */
    constructor() {
        // Assign the contract creator as the first admin
        _admins[msg.sender] = true;
    }




}