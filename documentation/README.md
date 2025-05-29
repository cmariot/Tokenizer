# 🪙 Tokenizer – NIEL42

## 🔰 Introduction

L'objectif de ce projet est de créer un token sur la blockchain.

Ce guide vous accompagnera à travers les étapes de déploiement et d'interaction avec un token ERC-20 sur la blockchain Sepolia, un réseau de test Ethereum.

## ⚙️ Prérequis

Environnement nécessaire :

- Node.js v22 ou supérieur
    ```zsh
    node -v
    ```

- npm v10 ou supérieur
    ```zsh
    npm -v
    ```

- Compte MetaMask configuré sur le réseau Sepolia

- Accès à des fonds de test Sepolia (via faucet)


## Structure du projet

Voici la structure principale du projet :

```zsh
.
├── contracts
│   └── Niel42.sol                  // Code du contrat intelligent
├── hardhat.config.ts               // Fichier de configuration Hardhat
├── ignition
│   └── modules
│       └── Niel42.ts               // Module de déploiement
├── package.json                    // Dépendances du projet
├── README.md
├── test
│   └── Niel42.ts                   // Tests unitaires
└── tsconfig.json                   // Configuration TypeScript
```


## 🧱 Structure du Token Niel42

- Type de token : [ERC-20](https://eips.ethereum.org/EIPS/eip-20), un standard pour les tokens fongibles sur Ethereum.
- Nom du token : Niel42
- Symbole : N42
- Nombre de décimales : 18
- Supply initial : 1 000 000 N42


## Déploiement et interaction avec le token :

Pour déployer et interagir avec le token Niel42, suivez ces étapes :

1. **Variables d'environnement** : Exportez vos variables d'environnement :
    ```zsh
    export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/your_alchemy_api_key_here"
    export SEPOLIA_PRIVATE_KEY="your_private_key_here"
    ```
    Remplacez `your_alchemy_api_key_here` par votre clé API Alchemy et `your_private_key_here` par votre clé privée Sepolia.

2. **Déploiement** : Déployez le contrat sur Sepolia :
    ```zsh
    make deploy
    ```


## 🛠️ Étapes de Création

- Rédaction du contrat intelligent
- Compilation
- Déploiement sur un réseau local puis sur Sepolia
- Vérification via block explorer ([Etherscan Sepolia](https://sepolia.etherscan.io/))
- Interaction avec le contrat (via Metamask et tests unitaires)


## 🧾 Vocabulaire Clé (Définitions simples)

Token : Actif numérique sur la blockchain.

Smart Contract : Programme auto-exécutable déployé sur la blockchain.

ERC-20 : Standard pour les tokens fongibles sur Ethereum.

Mint : Création de nouveaux tokens.

Burn : Destruction de tokens.

Blockchain : Registre distribué, transparent et immuable.



## 📎 Ressources utiles

<!-- Ethereum ERC-20 Standard -->
- [Ethereum ERC-20 Standard](https://eips.ethereum.org/EIPS/eip-20)

<!-- Hardhat -->
- [Hardhat](https://hardhat.org/)

<!-- Alchemy -->
- [Alchemy](https://www.alchemy.com/)

<!-- Ethereum Docs -->
- [Ethereum Docs](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)

<!-- OpenZeppelin Docs -->
- [OpenZeppelin](https://docs.openzeppelin.com/contracts/5.x/erc20)

<!-- Sepolia Faucet -->
- [Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)

<!-- Solidity Docs -->
- [Solidity Docs](https://docs.soliditylang.org/en/v0.8.28/)
