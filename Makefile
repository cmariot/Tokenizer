all: install compile test deploy

install:
	@echo "Installing dependencies..."
	@cd code && npm install

compile:
	@echo "Compiling smart contracts..."
	@cd code && npx hardhat compile

deploy:
	@echo "Deploying smart contracts..."
	@cd code && npx hardhat ignition deploy ignition/modules/Niel42.ts --network sepolia

test:
	@echo "Running tests..."
	@cd code && npx hardhat test test/Niel42.ts

clean:
	@echo "Cleaning up..."
	@cd code && npx hardhat clean || true
	@rm -rf code/cache

fclean: clean
	@echo "Full clean..."
	@cd code && rm -rf artifacts node_modules package-lock.json ignition/deployments

bonus: install_bonus compile_bonus test_bonus deploy_bonus

install_bonus:
	@echo "Installing bonus dependencies..."
	@cd bonus && npm install

compile_bonus:
	@echo "Compiling bonus smart contracts..."
	@cd bonus && npx hardhat compile

deploy_bonus:
	@echo "Deploying bonus smart contracts..."
	@cd bonus && npx hardhat ignition deploy ignition/modules/Niel42MultiSig.ts --network sepolia

test_bonus:
	@echo "Running bonus tests..."
	@cd bonus && npx hardhat test test/Niel42MultiSig.ts

clean_bonus:
	@echo "Cleaning up bonus..."
	@cd bonus && npx hardhat clean || true
	@rm -rf bonus/cache

fclean_bonus: clean_bonus
	@echo "Full clean bonus..."
	@cd bonus && rm -rf artifacts node_modules package-lock.json ignition/deployments

re: fclean all

re_bonus: fclean_bonus bonus

.PHONY: all install compile deploy test clean fclean install_bonus compile_bonus deploy_bonus test_bonus clean_bonus fclean_bonus