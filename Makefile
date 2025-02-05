CODE_DIR=./code

all: yarn compile test deploy

yarn:
	cd $(CODE_DIR) && yarn

compile:
	cd $(CODE_DIR) && yarn hardhat compile

test:
	cd $(CODE_DIR) && yarn hardhat test

deploy:
	cd $(CODE_DIR) && yarn hardhat ignition deploy ./ignition/modules/Coin42.js --network sepolia

clean:
	rm -rf $(CODE_DIR)/artifacts
	rm -rf $(CODE_DIR)/cache
	rm -rf $(CODE_DIR)/node_modules
	rm -rf $(CODE_DIR)/yarn.lock

.PHONY: all yarn compile test deploy
