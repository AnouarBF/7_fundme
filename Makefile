-include .env

clean:; forge clean

build:; forge build

install: 
	forge install smartcontractkit/chainlink-brownie-contracts \
	forge install cyfrin/foundry-devops \
	forge install OpenZeppelin/openzeppelin-contracts

test-localhost:; forge test

test-sepolia :; forge test --fork-url $(SEPOLIA_RPC_URL)

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe \
	--fork-url $(SEPOLIA_RPC_URL) \
	--account foxyBoy \
	--broadcast \
	--verify \
	--etherscan-api-key $(ETHERSCAN_API) 

deploy-localhost: 
	forge script script/DeployFundMe.s.sol:DeployFundMe 

fund-sepolia:
	forge script script/Interactions.s.sol:Fund --sender $(SENDER) \
	--fork-url $(SEPOLIA_RPC_URL) \
	--account foxyBoy \
	--broadcast \

withdraw-sepolia:
	forge script script/Interactions.s.sol:Withdraw --sender $(SENDER) \
	--fork-url $(SEPOLIA_RPC_URL) \
	--account foxyBoy \
	--broadcast \