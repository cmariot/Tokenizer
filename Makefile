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
	@cd code && npx hardhat clean
	@rm -rf code/cache

fclean: clean
	@echo "Full clean..."
	@cd code && rm -rf artifacts node_modules package-lock.json ignition/deployments

.PHONY: all install compile deploy test clean fclean