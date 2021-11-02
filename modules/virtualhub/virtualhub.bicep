var defaultTags = {
  ModuleName: 'vhub'
  ModuleVersion: '0.0.0.1'
}

// Standard Module Parameters

@description('Override standard resource name / governance naming standard.')
param name string = ''

@description('The purpose of the resource. Will be part of the name.')
param purpose string = ''

@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}


// Module Specific Parameters (Defaults Recommended)

@description('Address Prefix for this virtual hub')
param addressPrefix string

@description('Virtual Router Atonimic System Number (ASN) for BGP peering')
param virtualRouterAsn int

@description('Virtual Router IP Addresses')
param virtualRouterIps array

@description('Virtul Hub SKU to implement')
@allowed([
  'Standard'
])
param sku string = 'Standard'

@description('Virtual Hub Route Table  {/n  addressPrefixes: []/n  nextHopIpAddress: []/n}')
param routeTable array = []

@description('The preferred Routing Gateway Type')
@allowed([
  'VpnGateway'
  'None'
  'ExpressRoute'
])
param preferredRoutingGateway string = 'None'

@description('ResourceId of the connected VPN Gateway')
param vpnGatewayId string = ''

@description('ResourceId of the connected Virtual Wan')
param virtualWanId string = ''

@description('ResourceId of the connected Azure Firewall')
param azureFirewallId string = ''

@description('ResourceId of the connected Express Route Gateway')
param expressRouteGatewayId string = ''

@description('ResourceId of the connected Point to Site Gateway')
param p2SVpnGatewayId string = ''

@description('ResourceId of the connected Security Partner Provider')
param securityPartnerProviderId string = ''

@description('Name of the connected Security Partner Provider')
param securityProviderName string = ''

@description('Flag to control transit for VirutalRouter hub')
param allowBranchToBranchTraffic bool = true



// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)


// Governance Naming Standard
var nameLength = 80
var nameSuffix = '-hub'
var suffix = (((!empty(name)) || endsWith(purpose, nameSuffix)) ? '' : nameSuffix)
var prefix = take((empty(name) ? (startsWith(purpose, rgName) ? '${purpose}' : empty(purpose) ? '${rgName}' : '${rgName}-${purpose}') : name), (nameLength - length(suffix)))
var mainResourceName = '${prefix}${suffix}'


// Azure Resource Creation

resource mainResource 'Microsoft.Network/virtualHubs@2021-03-01' = {
  name: mainResourceName
  location: rgLocation
  tags: objResTags
  properties: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    addressPrefix: addressPrefix 
    azureFirewall: empty(azureFirewallId) ? null : {
      id: azureFirewallId
    }
    expressRouteGateway: empty(expressRouteGatewayId) ? null : {
      id: expressRouteGatewayId
    }
    p2SVpnGateway: empty(p2SVpnGatewayId) ? null : {
      id: p2SVpnGatewayId
    }
    //preferredRoutingGateway: preferredRoutingGateway
    routeTable: {
      routes: (empty(routeTable) ? null : routeTable)
    }
    securityPartnerProvider: empty(securityPartnerProviderId) ? null : {
      id: securityPartnerProviderId
    }
    securityProviderName: (empty(securityProviderName) ? null : securityProviderName)
    sku: (empty(sku) ? null : sku)
    virtualHubRouteTableV2s: []
    virtualRouterAsn: virtualRouterAsn
    virtualRouterIps: virtualRouterIps
    virtualWan: empty(virtualWanId) ? {} : {
      id: virtualWanId
    }
    vpnGateway: empty(vpnGatewayId) ? null :  {
      id: vpnGatewayId
    }
  }
} 




/*

// Diagnostics Settings
@description('List of log settings for the resource.')
param diagnosticSettingsLogs array = []

@description('List of metric settings for the resource.')
param diagnosticSettingsMetrics array = []

@description('Retention days for diagnostic logs and metrics archived to storage account.')
@minValue(0)
@maxValue(365)
param logsRetentionDays int = 30

var dsLogsDefault = [
  {
    category: 'Audit'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
]
var dsMetricsDefault = [
  {
    category: 'AllMetrics'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
]

var dsLogs = (empty(diagnosticSettingsLogs) ? dsLogsDefault : diagnosticSettingsLogs)
var dsMetrics = (empty(diagnosticSettingsMetrics) ? dsMetricsDefault : diagnosticSettingsMetrics)

resource mainResourceDiag 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = {
  scope: mainResource
  name: mainResourceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: mainResource.id
    logs: (empty(dsLogs) ? json('null') : dsLogs)
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}

*/

output id string = mainResource.id
output name string = mainResourceName
output virtualHubId string = mainResource.id
output virtualHubName string = mainResourceName
output resourceGroupName string = rgName
output tags object = objResTags
