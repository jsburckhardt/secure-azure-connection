using './main.bicep'

param rgName = ''
param identifier = 'someidentifier'
param location = 'eastus2'
param tagValues = {
  enddate: '31/10/2024'
  team: 'my team'
  project: 'the project'
  creator: 'the creator'
}
param newVpnGateway = false
param newPrivateDnsResolver = false
param inboundPrivateIpAddress = '10.1.254.5'
