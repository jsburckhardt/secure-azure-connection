PREFIX ?= sac
deploy:
	az deployment sub create --name secure-azure-connection \
		--location eastus2 \
		--template-file src/infra/main.bicep \
		--parameters src/infra/main.bicepparam \
		--parameters identifier=$(PREFIX) \
		--parameters location=eastus2 \
		--parameters newVpnGateway=true \
		--parameters newPrivateDnsResolver=true



link:
	az deployment group create --name vpnlinks \
		--resource-group rg-jb36cbk4 \
		--template-file src/infra/linkVpnVnet.bicep \
		--parameters linkConfig=@src/infra/linkConfigs.json
