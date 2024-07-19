param linkConfig object

module vpnLinks 'modules/privateLinkEndpoints.bicep' = [
  for link in linkConfig.links: {
    name: link.name
    params: {
      dnsZoneName: link.dnsZoneName
      networkLinkVpnName: link.networkLinkVpnName
      vnetId: link.vnetId
    }
  }
]
