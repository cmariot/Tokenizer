# SUDO42 Token Project

## Présentation

SUDO42 est un token ERC-20 déployé sur le réseau Sepolia. Il a été conçu dans le cadre du projet Tokenizer de l'ecole 42 pour illustrer le fonctionnement d'un token standard. Le nom du token est **SUDO42** et son symbole est **SUDO**. L'offre totale est de 1 000 000 tokens avec 18 décimales.

## Fonctionnalités principales

- Implémentation complète du standard ERC-20 (transfert, approbation, allowance, etc.)
- Attribution de l'intégralité de l'offre initiale au créateur du contrat
- Tests unitaires pour valider le comportement du token
- Déploiement automatisé via Hardhat Ignition

## Structure du projet

```
code/
  contracts/SUDO42.sol        # Contrat du token SUDO42
  test/SUDO42.js              # Tests unitaires du token
  ignition/modules/SUDO42.js  # Module de déploiement Ignition
  ...
Makefile                      # Commandes pour compiler, tester et déployer
```

## Prérequis
- Node.js
- Yarn
- Les variables d'environnement ALCHEMY_API_KEY (pour l'endpoint RPC) et SEPOLIA_PRIVATE_KEY (pour la clé privée du compte déployeur) doivent être définies. Vous pouvez les définir dans votre terminal ou dans un fichier `.env` :

```sh
export ALCHEMY_API_KEY=your_alchemy_api_key
export SEPOLIA_PRIVATE_KEY=your_sepolia_private_key
```

## Installation
1. Clonez le dépôt et placez-vous dans le dossier `code` :
   ```sh
   cd code
   yarn install
   ```

2. Configurez vos variables d'environnement (clé privée, endpoint RPC, etc.) dans `hardhat.config.js` ou via un fichier `.env` si nécessaire.

## Utilisation
Depuis la racine du projet :

- **Compiler le contrat :**
  ```sh
  make compile
  ```

- **Lancer les tests :**
  ```sh
  make test
  ```

- **Déployer sur Sepolia :**
  ```sh
  make deploy
  ```
  > Le déploiement utilise Hardhat Ignition et le module `SUDO42.js`.

- **Nettoyer le projet :**
  ```sh
  make clean
  ```

## Auteur
Projet réalisé par cmariot dans le cadre de 42.
