# 🪙 Tokenizer – NIEL42

## 🔰 Introduction

Ce projet a pour but de te faire découvrir le fonctionnement des tokens sur la blockchain Ethereum, à travers la création et le déploiement d’un token conforme au standard ERC-20.

La blockchain Ethereum est un registre distribué (une liste de transactions enregistrées chronologiquement et partagées entre plusieurs nœuds) qui permet le déploiement de contrats intelligents.

Les contrats intelligents sont du code déployé sur la blockchain avec lequel on peut interagir.

---

## 🌍 Qu’est-ce qu’un token ERC-20 ?

Un token ERC-20 est un actif numérique standardisé sur la blockchain Ethereum. Il peut représenter de la monnaie, des points de fidélité ou tout autre actif fongible. Les tokens ERC-20 sont compatibles avec de nombreux portefeuilles et applications.

---

## 🏗️ Les contrats intelligents du projet

### 1. Contrat principal : `Niel42.sol`
- **Type** : Token ERC-20 classique
- **Fonctionnalités** :
  - Détenir des tokens sur une adresse
  - Transférer des tokens à d’autres utilisateurs
  - Autoriser un tiers à dépenser des tokens pour soi (mécanisme d’approbation)
- **Paramètres** :
  - Nom : Niel42
  - Symbole : N42
  - Décimales : 18
  - Supply initial : 1 000 000 N42

### 2. Contrat bonus : `Niel42MultiSig.sol`
- **Type** : Token ERC-20 avec gestion multi-signature (multisig)
- **Fonctionnalités supplémentaires** :
  - Création (mint) et destruction (burn) de tokens
  - Ces actions sensibles nécessitent plusieurs validations (multi-signature) :
    - Un admin propose une action (mint/burn)
    - Les autres admins doivent approuver
    - L’action n’est exécutée que si le nombre requis d’approbations est atteint
  - Gestion des rôles :
    - Owner (propriétaire) : droits les plus élevés, peut ajouter/retirer des admins et modifier le nombre de signatures requises
    - Admins : peuvent approuver ou proposer des actions

#### 🗂️ Schéma simplifié du multisig

```
Proposition (mint/burn) → Approbations par les admins → Exécution si seuil atteint
```

---

## ⚙️ Prérequis

- Node.js v22 ou supérieur
- npm v10 ou supérieur
- Un compte MetaMask configuré sur le réseau Sepolia (testnet Ethereum)
- Des fonds de test Sepolia (obtenus via un faucet)

---

## 📁 Structure du projet

```
.
├── code/
│   ├── contracts/Niel42.sol           # Contrat principal ERC-20
│   └── ...
├── bonus/
│   ├── contracts/Niel42MultiSig.sol   # Contrat multisig (bonus)
│   └── ...
├── documentation/README.md            # Ce guide
└── ...
```

---

## 🚀 Déploiement étape par étape

1. **Configurer les variables d’environnement**
   - Récupère une clé API Alchemy et ta clé privée Sepolia (MetaMask).
   - Dans ton terminal :
     ```zsh
     export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/your_alchemy_api_key_here"
     export SEPOLIA_PRIVATE_KEY="your_private_key_here"
     ```

2. **Installer les dépendances**
   - Place-toi dans le dossier racine.
   - Installe les dépendances :
     ```zsh
     make install
     make install_bonus
     ```

3. **Compiler le smart contract**
    - En utilisant Hardhat :
      ```zsh
      make compile
      make compile_bonus
      ```

4. **Lancer les tests pour vérifier le fonctionnement des tokens**
     - Via Hardhat avec le framework de test intégré à Node.js :
       ```zsh
       make test
       make test_bonus
       ```

5. **Déployer le contrat sur la blockchain**
   - Depuis le dossier racine :
     ```zsh
     make deploy
     make deploy_bonus
     ```
    À la fin du déploiement, l’adresse du contrat sera affichée dans le terminal.

6. **Vérifier le contrat**
   - Utilise [Etherscan Sepolia](https://sepolia.etherscan.io/) pour vérifier l’adresse et l’état du contrat.

7. **Interagir avec le contrat**
   - Via MetaMask, Hardhat ou les tests unitaires fournis dans le dossier `test/`.

---

## 🧾 Vocabulaire clé

- **Token** : Actif numérique sur la blockchain
- **Smart Contract** : Programme auto-exécutable sur la blockchain
- **ERC-20** : Standard pour les tokens fongibles sur Ethereum
- **Mint** : Création de nouveaux tokens
- **Burn** : Destruction de tokens
- **Blockchain** : Registre distribué, transparent et immuable
- **Multisig** : Système où plusieurs signatures sont nécessaires pour valider une action
- **Admin** : Personne ayant des droits de gestion sur le contrat
- **Owner** : Propriétaire du contrat, avec tous les droits

---

## 📎 Ressources utiles

- [Ethereum ERC-20 Standard](https://eips.ethereum.org/EIPS/eip-20)
- [Hardhat](https://hardhat.org/)
- [Alchemy](https://www.alchemy.com/)
- [Ethereum Docs](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)
- [OpenZeppelin](https://docs.openzeppelin.com/contracts/5.x/erc20)
- [Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)
- [Solidity Docs](https://docs.soliditylang.org/en/v0.8.28/)

---

N’hésite pas à lire le code source des contrats pour mieux comprendre leur fonctionnement, ou à consulter les tests pour voir des exemples d’utilisation !
