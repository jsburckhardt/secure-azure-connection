param dnsZoneName string
param networkLinkVpnName string
param vnetId string

// storage blob
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: dnsZoneName
}

// storage blob
resource virtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: networkLinkVpnName
  parent: dnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}
