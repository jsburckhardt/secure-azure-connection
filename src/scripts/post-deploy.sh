#!/bin/bash

# Run az deployment and capture the output
deployment_output=$(az deployment group show --name <deployment_name> --resource-group <resource_group_name> --query properties.outputs --output json)

# Extract the required values from the deployment output
vnet_name=$(echo "$deployment_output" | jq -r '.vnetName.value')
vnet_resource_group=$(echo "$deployment_output" | jq -r '.vnetResourceGroup.value')
vnet_peering_name=$(echo "$deployment_output" | jq -r '.vnetPeeringName.value')
remote_vnet_id=$(echo "$deployment_output" | jq -r '.remoteVnetId.value')

# Update the DNS of the VNet
az network vnet update --name "$vnet_name" --resource-group "$vnet_resource_group" --dns-servers "8.8.8.8" "8.8.4.4"

# Create a VNet peering
az network vnet peering create --name "$vnet_peering_name" --resource-group "$vnet_resource_group" --vnet-name "$vnet_name" --remote-vnet "$remote_vnet_id" --allow-vnet-access

# Add any additional commands or logic here

# configure vpnGateway with a point to site vpn using openvpn config and certificate. Then download the VPN client configuration
az network vpn-gateway vpn-client generate --name <vpn_gateway_name> --resource-group <resource_group_name> --output json > vpn-client-config.zip
