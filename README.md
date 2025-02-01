# Tokenizer : Build and deploy a token on Ethereum blockchain


- Name of the token : Coin42
- Blockchain : Sepolia (Ethereum testnet)
- Standard : ERC-20


## Repository structure

```bash
.
├── code
│   ├── contracts
│   ├── package.json
│   └── scripts
├── deployment
├── documentation
└── README.md
```

The code folder contains the files used to create the token.
The deployment folder contains the files used to deploy the token on the blockchain.
There is also a documentation folder that contains the documentation of the project.


## Token's code

The development environment is managed by yarn.
The token's code is written in Solidity, a language used to write smart contracts on the Ethereum blockchain. The code is located in the contracts folder.

```solidity

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";  // OpenZeppelin package contains implementation of the ERC 20 standard, which our NFT smart contract will inherit

contract Coin42 is ERC20 {
    uint constant _initial_supply = 100 * (10**18);  // setting variable for how many of your own tokens are initially put into your wallet, feel free to edit the first number but make sure to leave the second number because we want to make sure our supply has 18 decimals

    /* ERC 20 constructor takes in 2 strings, feel free to change the first string to the name of your token name, and the second string to the corresponding symbol for your custom token name */
    constructor() ERC20("Coin42", "42C") public {
        _mint(msg.sender, _initial_supply);
    }
}

```