@description('The name of the public IP address')
param publicIpName string
@description('The name of the VPN gateway')
param vpnGatewayName string
@description('The ID of the gateway subnet')
param gatewaySubnetId string

// public ip address
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// virtual network gateway
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-11-01' = {
  name: vpnGatewayName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    gatewayType: 'Vpn'
    enableBgp: false
    ipConfigurations: [
      {
        name: 'vpnGatewayIpConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]
  }
}
