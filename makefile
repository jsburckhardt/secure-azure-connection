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

links:
	az deployment sub show --name aistudio-managed-vnet --query properties.outputs > hub.output.json
	targetVnetId=$$(jq -r '.vnetId.value' hub.output.json); \
	targetResourGroupName=$$(jq -r '.rgName.value' vpn.output.json); \
	az deployment group create --name vpnlinks \
		--resource-group $$targetResourGroupName \
		--template-file src/infra/linkVpnVnet.bicep \
		--parameters vnetId=$$vnetId \
		--parameters linkConfig=@src/infra/linkConfigs.json
