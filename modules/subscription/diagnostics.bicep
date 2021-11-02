// Subscription Diagnostics
targetScope = 'subscription'

var defaultTags = {
  ModuleName: 'subscription.diagnostics'
  ModuleVersion: '0.0.0.1'
}


// Standard Module Optional Parameters 

@description('Tag resource with custom tags.')
param tags object = {}

// Module Specific Optional Parameters

@description('The list of log settings for the Subscription.')
param diagnosticSettingsLogs array = []

@description('The list of metric settings for the Subscription.')
param diagnosticSettingsMetrics array = []

@description('Retention days for diagnostic logs and metrics archived to storage account.')
@minValue(0)
@maxValue(365)
param logsRetentionDays int = 0

@description('Archive diagnostic logs and metrics to this storage account.')
param storageId string = ''

@description('Log Analytics workspace used for diagnostic log integration.')
param workspaceId string

// Standard Module Variables
var objResTags = union(defaultTags, tags)

var dsLogsDefault = [
  {
    category: 'Administrative'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'Security'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'ServiceHealth'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'Alert'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'Recommendation'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'Policy'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'Autoscale'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
  {
    category: 'ResourceHealth'
    enabled: true
    retentionPolicy: {
      days: (empty(storageId) ? 0 : logsRetentionDays)
      enabled: (empty(storageId) ? json('false') : json('true'))
    }
  }
]
var dsLogs = (empty(diagnosticSettingsLogs) ? dsLogsDefault : diagnosticSettingsLogs)
var dsMetrics = diagnosticSettingsMetrics
var mainResourceName = (empty(workspaceId) ? 'dummy' : last(split(workspaceId, '/')))

resource mainResource 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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
output tags object = objResTags
