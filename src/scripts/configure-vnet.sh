#!/bin/bash

##############################################
### Get details from the deployment output ###
##############################################

# Get script path
script_path="$(dirname "$(realpath "$0")")"
hub_output_path="$script_path/../../hub.output.json"
vpn_output_path="$script_path/../../vpn.output.json"

# Validate if files exist
if [ ! -f "$hub_output_path" ] || [ ! -f "$vpn_output_path" ]; then
    echo "Deployment output files not found. Please run the deployment script first."
    exit 1
fi

# Extract the required values from the deployment output
DNS_SERVER=$(jq -r '.inboundPrivateIpAddress.value' "$vpn_output_path")
VPN_VNET_ID=$(jq -r '.vnetId.value' "$vpn_output_path")
VPN_VNET_RG=$(jq -r '.resourceGroupName.value' "$vpn_output_path")
VPN_VNET_NAME=$(jq -r '.vnetName.value' "$vpn_output_path")
SPOKE_VNET_ID=$(jq -r '.vnetId.value' "$hub_output_path")
SPOKE_VNET_RG=$(jq -r '.rgName.value' "$hub_output_path")
SPOKE_VNET_NAME=$(jq -r '.vnetName.value' "$hub_output_path")

# Use AZ to update the VNET DNS server
echo "Updating the DNS server of the VNet..."
az network vnet update --ids "$VPN_VNET_ID" --dns-servers "$DNS_SERVER"
echo "DNS server updated successfully."

# Configure VPN Peering
echo "Configuring VPN Peering..."
echo "Starting peering from VPN to SPOKE..."
az network vnet peering create --name "vpn-to-spoke" \
    --resource-group "$VPN_VNET_RG" \
    --vnet-name "$VPN_VNET_NAME" \
    --remote-vnet "$SPOKE_VNET_ID" \
    --allow-forwarded-traffic "true" \
    --allow-gateway-transit "true" \
    --allow-vnet-access "true" \
    --use-remote-gateways "false"
echo "Peering from VPN to SPOKE completed successfully."

echo "Starting peering from SPOKE to VPN..."
az network vnet peering create --name "spoke-to-vpn" \
    --resource-group "$SPOKE_VNET_RG" \
    --vnet-name "$SPOKE_VNET_NAME" \
    --remote-vnet "$VPN_VNET_ID" \
    --allow-forwarded-traffic "true" \
    --allow-gateway-transit "false" \
    --allow-vnet-access "true" \
    --use-remote-gateways "true"
echo "Peering from SPOKE to VPN completed successfully."
echo "VPN Peering configured successfully."

# Now configure the vpn gateway
# We will need to create a self sign certificate and install it in the VPN Gateway
