// Azure Automation Account

var defaultTags = {
  ModuleName: 'automation'
  ModuleVersion: '0.0.0.1'
}


// Standard Module Optional Parameters 

@description('Override standard resource name / governance naming standard.')
param name string = ''

@description('The purpose of the resource. Will be part of the name.')
param purpose string = ''

@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}

// Module Specific Optional Parameters

@description('SKU of the Automation Account to Deploy, Defaults to Basic')
@allowed([
  'Basic'
  'Free'
])
param sku string = 'Basic'

@description('Archive diagnostic logs and metrics to this storage account.')
param storageId string = ''

@description('The Log Analytics Workspace ID which will be associated with the automation account.')
param workspaceId string

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)

// Governance Naming Standard
var unique = take(uniqueString(subscription().id, resourceGroup().id), 10)
var nameLength = 50
var nameSuffix = '-auto'
var suffix = (((!empty(name)) || endsWith(purpose, nameSuffix)) ? '' : nameSuffix)
var prefix = take((empty(name) ? (startsWith(purpose, rgName) ? '${purpose}${unique}' : empty(purpose) ? '${rgName}${unique}' : '${rgName}-${purpose}${unique}') : name), (nameLength - length(suffix)))
var mainResourceName = '${prefix}${suffix}'


// Create Log Analytics Workspace
resource mainResource 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: mainResourceName
  location: rgLocation
  tags: objResTags
  properties: {
    sku: {
      name: sku
    }
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
    category: 'JobStreams'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'JobLogs'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'DscNodeStatus'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'AuditEvent'
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


resource mainResourceDiag 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!(empty(workspaceId))) {
  scope: mainResource
  name: mainResourceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: workspaceId
    logs: (empty(dsLogs) ? json('null') : dsLogs)
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}



output id string = mainResource.id
output name string = mainResourceName
output automationId string = mainResource.id
output automationName string = mainResourceName
output resourceGroupName string = rgName
output tags object = objResTags
