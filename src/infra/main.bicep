targetScope = 'subscription'

// ##########################################
// Params
// ##########################################

// global
@description('Resource group name')
param rgName string = ''

@description('Deployment name - identifier')
param identifier string

@description('Primary location for all resources')
param location string = 'eastus2'

@description('Tags for workspace, will also be populated if provisioning new dependent resources.')
param tagValues object = {}

// global vars
var abbrs = loadJsonContent('abbreviations.json')
var rgNameVar = !empty(rgName) ? rgName : '${abbrs.resourcesResourceGroups}${identifier}'
var uniqueSuffix = substring(uniqueString(rgNameVar), 0, 5)
var prefix = toLower('${identifier}')

// vpn gateway
param newVpnGateway bool = false

// dns resolver
param newPrivateDnsResolver bool = false
param inboundPrivateIpAddress string = '10.1.254.5'

// ##########################################
// Resources
// ##########################################

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(rgName) ? rgName : '${abbrs.resourcesResourceGroups}${prefix}-${uniqueSuffix}'
  location: location
  tags: tagValues
}

module vnetModule 'modules/vnet.bicep' = {
  name: 'vnetModule'
  scope: rg
  params: {
    vnetName: '${abbrs.resourcesResourceGroups}${prefix}-${uniqueSuffix}'
    subnetPrivateDnsResolverName: '${abbrs.networkVirtualNetworksSubnets}-PrivateDnsResolverSubnet'
    location: location
    tagValues: tagValues
    addressPrefixes: ['10.1.0.0/16']
  }
}

// Include the vpnGateway module
module vpnGatewayModule 'modules/vpnGateway.bicep' = if (newVpnGateway) {
  name: 'vpnGatewayModule'
  scope: rg
  params: {
    publicIpName: '${abbrs.networkPublicIPAddresses}${prefix}-${uniqueSuffix}'
    vpnGatewayName: '${abbrs.networkVpnGateways}${prefix}-${uniqueSuffix}'
    gatewaySubnetId: vnetModule.outputs.gatewaySubnetId
  }
}

module dnsResolver 'modules/privateDnsResolver.bicep' = if (newPrivateDnsResolver) {
  name: 'privateDnsResolverModule'
  scope: rg
  params: {
    privateDnsResolverSubnetId: vnetModule.outputs.privateDnsResolverSubnetId
    resolverName: '${abbrs.networkPrivateDnsResolver}${prefix}-${uniqueSuffix}'
    vnetId: vnetModule.outputs.vnetId
    inboundPrivateIpAddress: inboundPrivateIpAddress
  }
}
