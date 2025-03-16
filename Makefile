include .env






build:
	forge build

deploy-sepolia:
	forge script script/DeployFundme.s.sol:DeployFundme --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
