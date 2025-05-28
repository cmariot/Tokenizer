# 🪙 Tokenizer – NIEL42

## 🔰 Introduction

L'objectif de ce projet est de créer un token sur la blockchain.

Ce guide vous accompagnera à travers les étapes de création, déploiement et interaction avec un token ERC-20 sur la blockchain Sepolia, un réseau de test Ethereum.

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







## 🧱 Structure du Token

Type de token (ex: ERC-20, ERC-721…)

Nom du token (ex: MyToken)

Symbole (ex: MYT)

Nombre de décimales (ex: 18)

Supply initial

Mintable / Burnable / Pausable ?

Permissions (Owner, minter…)

## 🛠️ Étapes de Création

Rédaction du contrat intelligent

Compilation

Déploiement sur un réseau de test

Vérification via block explorer (Etherscan / BscScan)

Interaction avec le contrat (via Remix, scripts ou frontend)

## 🧪 Test et Validation

Tests unitaires (si existants)

Vérification du bon comportement :

    Transfert de tokens

    Lecture du solde

    Gestion des erreurs

## 🧾 Vocabulaire Clé (Définitions simples)

Token : Actif numérique sur la blockchain.

Smart Contract : Programme auto-exécutable déployé sur la blockchain.

ERC-20 : Standard pour les tokens fongibles sur Ethereum.

Mint : Création de nouveaux tokens.

Burn : Destruction de tokens.

Blockchain : Registre distribué, transparent et immuable.

## 🔒 Sécurité et Bonnes Pratiques

Vérifier les accès et rôles

Ne jamais exposer de clés privées

Utiliser des bibliothèques éprouvées (OpenZeppelin)

Faire auditer le contrat avant mise en production

## 📡 Déploiement sur le Réseau Principal

Préparer le contrat (vérifié et audité)

Déployer sur le mainnet

Ajouter le token dans MetaMask

Communiquer l’adresse du contrat

## 📎 Ressources utiles

<!-- OpenZeppelin Docs -->

<!-- Ethereum Docs -->

<!-- Remix IDE -->

[Hardhat](https://hardhat.org/)

<!-- Etherscan Verification Guide -->