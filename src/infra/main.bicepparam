using './main.bicep'

param rgName = ''
param identifier = 'jb3'
param location = 'eastus2'
param tagValues = {
  enddate: '31/10/2024'
  team: 'taipan'
  project: 'asktelstrav2'
  creator: 'juan'
}
param newVpnGateway = false
param newPrivateDnsResolver = false
param inboundPrivateIpAddress = '10.1.254.5'
