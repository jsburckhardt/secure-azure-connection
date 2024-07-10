targetScope = 'subscription'

param resourceGroupName string
param location string = 'eastus2'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module vnetModule 'modules/vnet.bicep' = {
  name: 'vnetModule'
  scope: rg
  params: {
    vnetName: 'myVnet'
    vnetAddressPrefix: '10.0.0.0/16'
    subnetName: 'mySubnet'
    subnetAddressPrefix: '10.0.0.0/24'
  }
}

resource vpnGateway 'Microsoft.Network/vpnGateways@2021-02-01' = {
  name: 'myVpnGateway'
  location: location
  properties: {
    vpnGatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          subnet: {
            id: vnetModule.outputs.subnetId
          }
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2021-06-01' = {
  name: 'privatednszone.com'
  location: location
  properties: {
    privateZoneName: 'privatednszone.com'
  }
}
