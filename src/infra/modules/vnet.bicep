param vnetName string
param location string
param tagValues object
param addressPrefixes array
param subnetPrivateDnsResolverName string

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }

    subnets: [
      {
        name: subnetPrivateDnsResolverName
        properties: {
          addressPrefix: '10.1.254.0/24'
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.1.255.0/24'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output privateDnsResolverSubnetId string = vnet.properties.subnets[0].id
output gatewaySubnetId string = vnet.properties.subnets[1].id
