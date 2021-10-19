var defaultTags = {
  ModuleName: 'workspace'
  ModuleVersion: '0.0.0.1'
}

// Parameters for the Module

@description('Override standard resource name / governance naming standard.')
param name string = ''

@description('The purpose of the resource. Will be part of the name.')
param purpose string = ''

@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}

@description('Duration to retain the data in workspace, Defaults to 365 Days.')
param retentionInDays int = 365

@description('SKU of the Log Analytics Workspace to Deploy')
@allowed([
  'CapacityReservation'
  'LACluster'
  'Free'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerGB2018'

@description('Archive diagnostic logs and metrics to this storage account.')
param storageId string = ''

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)

// Governance Naming Standard
var unique = take(uniqueString(subscription().id, resourceGroup().id), 10)
var nameLength = 63
var nameSuffix = '-ws'
var suffix = (((!empty(name)) || endsWith(purpose, nameSuffix)) ? '' : nameSuffix)
var prefix = take((empty(name) ? (startsWith(purpose, rgName) ? '${purpose}${unique}' : empty(purpose) ? '${rgName}${unique}' : '${rgName}-${purpose}${unique}') : name), (nameLength - length(suffix)))
var mainResourceName = '${prefix}${suffix}'



// Create Log Analytics Workspace
resource mainResource 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: mainResourceName
  location: rgLocation
  tags: objResTags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions:true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}


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



output id string = mainResource.id
output name string = mainResourceName
output customerId string = mainResource.properties.customerId
output workspaceId string = mainResource.id
output workspaceName string = mainResourceName
output workspaceCustomerId string = mainResource.properties.customerId
output resourceGroupName string = rgName
