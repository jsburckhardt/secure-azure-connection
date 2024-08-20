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
	az deployment sub show --name secure-azure-connection --query properties.outputs > vpn.output.json
	@export $$(cat .env | xargs) && \
	vpnVnetId=$$(jq -r '.vnetId.value' vpn.output.json); \
	hubResourGroupName=$$HUB_VNET_RG; \
	az deployment group create --name vpnlinks \
    	--resource-group $$hubResourGroupName \
    	--template-file src/infra/linkVpnVnet.bicep \
    	--parameters vnetId=$$vpnVnetId \
    	--parameters linkConfig=@src/infra/linkConfigs.json

configure:
	./src/scripts/configure-vnet.sh
