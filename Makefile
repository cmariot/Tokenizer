install:
	@echo "Installing dependencies..."
	@cd code && \
		npm install

compile: install
	@echo "Compiling smart contracts..."
	@cd code && \
		npx hardhat compile

deploy: compile
	@echo "Deploying smart contracts..."
	@cd code && \
		npx hardhat ignition deploy ignition/modules/Niel42.ts --network sepolia

test: install
	@echo "Running tests..."
	@cd code && \
		npx hardhat test test/Niel42.ts

clean: install
	@echo "Cleaning up..."
	@cd code && \
		npx hardhat clean
	@ rm -rf code/cache

fclean: clean
	@cd code && \
	    rm -rf artifacts node_modules package-lock.json ignition/deployments