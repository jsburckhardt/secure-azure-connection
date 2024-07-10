using './main.bicep'

param rgName = ''
param identifier = 'jb3'
param location = 'eastus2'
param tagValues = {}
param newVpnGateway = true
param newPrivateDnsResolver = true
param inboundPrivateIpAddress = '10.1.254.5'
