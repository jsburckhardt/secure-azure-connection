#!/bin/bash
set -e

##############################################
### Get details from the deployment output ###
##############################################

# Get script path
script_path="$(dirname "$(realpath "$0")")"
vpn_output_path="$script_path/../../vpn.output.json"

# Validate if files exist
if [ ! -f "$vpn_output_path" ]; then
    echo "Deployment output files not found. Please deploy the vpn resources first."
    exit 1
fi

# validate .env file exists
if [ ! -f "$script_path/../../.env" ]; then
    echo "Please create a .env file in the root of the project."
    exit 1
fi

# Load the .env file
source "$script_path/../../.env"

# Check HUB_SUBSCRIPTION_ID, HUB_VNET_RG and HUB_VNET_NAME aren't empty
if [ -z "$HUB_SUBSCRIPTION_ID" ] || [ -z "$HUB_VNET_RG" ] || [ -z "$HUB_VNET_NAME" ]; then
    echo "Please provide values for HUB_SUBSCRIPTION_ID, HUB_VNET_RG and HUB_VNET_NAME in the .env file."
    exit 1
fi

# Extract the required values from the deployment output
DNS_SERVER=$(jq -r '.inboundPrivateIpAddress.value' "$vpn_output_path")
VPN_VNET_ID=$(jq -r '.vnetId.value' "$vpn_output_path")
VPN_VNET_RG=$(jq -r '.rgName.value' "$vpn_output_path")
VPN_VNET_NAME=$(jq -r '.vnetName.value' "$vpn_output_path")
HUB_VNET_ID="/subscriptions/$HUB_SUBSCRIPTION_ID/resourceGroups/$HUB_VNET_RG/providers/Microsoft.Network/virtualNetworks/$HUB_VNET_NAME"

# Use AZ to update the VNET DNS server
echo "Updating the DNS server of the VNet..."
az network vnet update --ids "$VPN_VNET_ID" --dns-servers "$DNS_SERVER"
echo "DNS server updated successfully."

# Configure VPN Peering
echo "Configuring VPN Peering..."
echo "Starting peering from VPN to HUB..."
az network vnet peering create --name "vpn-to-hub" \
    --resource-group "$VPN_VNET_RG" \
    --vnet-name "$VPN_VNET_NAME" \
    --remote-vnet "$HUB_VNET_ID" \
    --allow-forwarded-traffic "true" \
    --allow-gateway-transit "true" \
    --allow-vnet-access "true" \
    --use-remote-gateways "false"
echo "Peering from VPN to HUB completed successfully."

echo "Starting peering from HUB to VPN..."
az network vnet peering create --name "hub-to-vpn" \
    --resource-group "$HUB_VNET_RG" \
    --vnet-name "$HUB_VNET_NAME" \
    --remote-vnet "$VPN_VNET_ID" \
    --allow-forwarded-traffic "true" \
    --allow-gateway-transit "false" \
    --allow-vnet-access "true" \
    --use-remote-gateways "true"
echo "Peering from HUB to VPN completed successfully."
echo "VPN Peering configured successfully."

# Now configure the vpn gateway
# We will need to create a self sign certificate and install it in the VPN Gateway
