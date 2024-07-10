@description('The ID of the private DNS resolver subnet')
param privateDnsResolverSubnetId string
@description('The name of the DNS private resolver')
param resolverName string
@description('The ID of the virtual network')
param vnetId string
@description('The inbound private IP address.')
param inboundPrivateIpAddress string



// dns private resolver
resource dnsPrivateResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: resolverName
  location: resourceGroup().location
  properties: {
    virtualNetwork: {
      id: vnetId
    }
  }
  resource inboundEndpoints 'inboundEndpoints@2022-07-01' = {
    name: '${resolverName}-adpr-pep'
    location: resourceGroup().location
    properties: {
      ipConfigurations: [
        {
          privateIpAllocationMethod: 'Static'
          privateIpAddress: inboundPrivateIpAddress
          subnet: {
            id: privateDnsResolverSubnetId

          }
        }
      ]
    }
  }
}
