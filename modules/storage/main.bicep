// Azure Automation Account

var defaultTags = {
  ModuleName: 'storage'
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

@description('SKU of the Storage Account to Deploy, Defaults to Standard_GRS')
@allowed([
  'Standard_ZRS'
  'Standard_RAGZRS'
  'Standard_RAGRS'
  'Standard_LRS'
  'Standard_GZRS' 
  'Standard_GRS'
  'Premium_ZRS'
  'Premium_LRS'
])
param sku string = 'Standard_GRS'

@description('SKU of the Storage Account to Deploy, Defaults to StorageV2')
@allowed([
  'FileStorage'
  'Storage'
  'StorageV2'
  'BlockBlobStorage'
  'BlobStorage'
])
param kind string = 'StorageV2'

@description('The resource name unique code.')
param uniqueCode string = ''

@description('Archive diagnostic logs and metrics to this storage account.')
param storageId string = ''

@description('The Log Analytics Workspace ID which will be associated with the automation account.')
param workspaceId string

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)

// Governance Naming Standard
var unique = (empty(uniqueCode) ? uniqueString(subscription().id, resourceGroup().id) : uniqueString(subscription().id, resourceGroup().id, uniqueCode))
var nameLength = 23
var suffix = ''
var prefix = toLower(take(replace((empty(name) ? (startsWith(purpose, rgName) ? '${purpose}${unique}' : '${rgName}${purpose}${unique}') : name), '-', ''), (nameLength - length(suffix))))
var mainResourceName = '${prefix}${suffix}'

// Module Specific References
var strWorkspaceName = last(split(workspaceId,'/'))

// Create Storage Account
resource mainResource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: mainResourceName
  location: rgLocation
  tags: objResTags
  sku :{
    name:  sku
  }
  kind: kind
  properties: {
     
  }
}

// Storage Life Cycle Management Policy

@description('The Data Policy Rules.')
param managementPolicy object = {}



resource mainResourceManagementPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2021-04-01' = if (!empty(managementPolicy)) {
  parent: mainResource
  name: 'default'
  properties: managementPolicy
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
    category: 'StorageRead'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'StorageWrite'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'StorageDelete'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
]

var dsMetricsDefault = [
  {
    category: 'Capacity'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'Transaction'
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
  name: strWorkspaceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: workspaceId
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}



// Blobs

@description('The Blob Service properties.')
param blobServiceProperties object = {
  deleteRetentionPolicy: {
    enabled: false
  }
}

resource mainResourceBlobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = if (!(kind == 'FileStorage') && (!(empty(blobServiceProperties)))) {
  parent: mainResource
  name: 'default'
  properties: blobServiceProperties
}

resource mainResourceBlobServiceDiag 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(workspaceId)) && (!(kind == 'FileStorage') && (!(empty(blobServiceProperties))))) {
  scope: mainResourceBlobService
  name: strWorkspaceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: workspaceId
    logs: (empty(dsLogs) ? json('null') : dsLogs)
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}

// Queues

@description('The Queue Service properties.')
param queueServiceProperties object = {}

resource mainResourceQueueService 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = if ((!(kind == 'BlobStorage')) && (!(kind == 'BlockBlobStorage')) && (!(kind == 'FileStorage')) && (!(empty(queueServiceProperties)))) {
  parent: mainResource
  name: 'default'
  properties: queueServiceProperties
}

resource mainResourceQueueServiceDiag 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(workspaceId)) && (!(kind == 'BlobStorage')) && (!(kind == 'BlockBlobStorage')) && (!(kind == 'FileStorage')) && (!(empty(queueServiceProperties)))) {
  scope: mainResourceQueueService
  name: strWorkspaceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: workspaceId
    logs: (empty(dsLogs) ? json('null') : dsLogs)
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}

// Tables
@description('The Table Service properties.')
param tableServiceProperties object = {}

resource mainResourceTableService 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = if ((!(kind == 'BlobStorage')) && (!(kind == 'BlockBlobStorage')) && (!(kind == 'FileStorage')) && (!(empty(tableServiceProperties)))) {
  parent: mainResource
  name: 'default'
  properties: tableServiceProperties
}

resource mainResourceTableServiceDiag 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(workspaceId)) && (!(kind == 'BlobStorage')) && (!(kind == 'BlockBlobStorage')) && (!(kind == 'FileStorage')) && (!(empty(tableServiceProperties)))) {
  scope: mainResourceTableService
  name: strWorkspaceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: workspaceId
    logs: (empty(dsLogs) ? json('null') : dsLogs)
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}

// File Services

@description('The File Service properties.')
param fileServiceProperties object = {
  shareDeleteRetentionPolicy: {
    days: 7
    enabled: true
  }
}

resource mainResourceFileService 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = if ((!(kind == 'BlobStorage')) && (!(kind == 'BlockBlobStorage')) && (!(empty(fileServiceProperties)))) {
  parent: mainResource
  name: 'default'
  properties: fileServiceProperties
}

resource mainResourceFileServiceDiag 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(workspaceId)) && (!(kind == 'BlobStorage')) && (!(kind == 'BlockBlobStorage')) && (!(empty(fileServiceProperties)))) {
  scope: mainResourceFileService
  name: strWorkspaceName
  properties: {
    storageAccountId: (empty(storageId) ? json('null') : storageId)
    workspaceId: workspaceId
    logs: (empty(dsLogs) ? json('null') : dsLogs)
    metrics: (empty(dsMetrics) ? json('null') : dsMetrics)
  }
}


// ::


output id string = mainResource.id
output name string = mainResourceName
output storageId string = mainResource.id
output storageName string = mainResourceName
output resourceGroupName string = rgName
