#!/bin/bash

# Se placer dans le dossier code du projet
cd "$(dirname "$0")/../code" || exit 1

# Installer les dépendances
npm install

# Compiler le contrat
npx hardhat compile

# Déployer le contrat
npx hardhat ignition deploy ignition/modules/Niel42.ts --network sepolia
