var defaultTags = {
  ModuleName: 'workspace'
  ModuleVersion: '0.0.0.1'
}

@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}

@description('List of log search alerts.')
param rules array

@description('The Resource Id of an action group that will be set as action for the rules.')
param actionGroupId string = ''

@description('Log Analytics workspace over which log search query is to be run.')
param workspaceId string

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)



resource scheduledQueryRule 'microsoft.insights/scheduledQueryRules@2018-04-16' = [for (item, i) in rules: {
  name: (contains(item, 'name') ? item.name : 'Log Search Alert ${padLeft((i + 1), 3, '0')}')
  location: rgLocation
  tags: objResTags
  properties: {
    description: (contains(item, 'description') ? item.description : '')
    enabled: (contains(item, 'enabled') ? bool(item.enabled) : bool('true'))
    source: {
      query: item.query
      dataSourceId: workspaceId
      queryType: 'ResultCount'
    }
    schedule: {
      frequencyInMinutes: item.frequency
      timeWindowInMinutes: item.time
    }
    action: {
      'odata.type': 'Microsoft.WindowsAzure.Management.Monitoring.Alerts.Models.Microsoft.AppInsights.Nexus.DataContracts.Resources.ScheduledQueryRules.AlertingAction'
      severity: item.severityLevel
      throttlingInMin: item.suppressTimeinMin
      aznsAction: {
        actionGroup: ((contains(item, 'actionGroupIds') && (!empty(item.actionGroupIds))) ? item.actionGroupIds : ((!empty(actionGroupId)) ? array(actionGroupId) : json('null')))
        emailSubject: item.description
      }
      trigger: {
        thresholdOperator: item.operator
        threshold: item.threshold
      }
    }
  }
}]

output alertList array = [for (item, i) in rules: {
  resourceId: resourceId('microsoft.insights/scheduledQueryRules', (contains(item, 'name') ? item.name : 'Log Search Alert ${padLeft((i + 1), 3, '0')}'))
  name: (contains(item, 'name') ? item.name : 'Log Search Alert ${padLeft((i + 1), 3, '0')}')
}]
output resourceGroupName string = rgName
output tags object = objResTags
