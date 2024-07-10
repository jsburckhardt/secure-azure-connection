PREFIX ?= sac
deploy:
	az deployment sub create --name secure-azure-connection \
		--location eastus2 \
		--template-file src/infra/main.bicep \
		--parameters infra/main.bicepparam \
		--parameters prefix=$(PREFIX) \
		--parameters location=eastus2 \
		--parameters ciConfig=@infra/computeInstances.json
