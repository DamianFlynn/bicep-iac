targetScope='subscription'

var defaultTags = {
  ServiceName: 'management'
  ServiceVersion: '0.0.0.2'
}

param location string
@description('Tag resource with custom tags.')
param tags object = {}


var objResTags = union(defaultTags, tags)
var strRGMon = 'p-mgt-mon'
var strRGAuto = 'p-mgt-auto'
var strRGGovLog = 'p-gov-log'

// ::
// p-gov-log
//
// - res.arm.storage.audit

resource rgGovLog 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: strRGGovLog
  location: location
  tags: objResTags
}

module resStorageAudit '../../modules/storage/main.bicep' = {
  scope: resourceGroup(rgGovLog.name)
  name: 'res.arm.storage.audit'
  params: {
    sku: 'Standard_GRS'
    kind: 'StorageV2'
    tags: objResTags
    purpose: 'audit'
    workspaceId: resWorkspace.outputs.id
    managementPolicy: {
      policy: {
        rules:  [
          {
            enabled: true
            name: 'TieringRule'
            type: 'Lifecycle'
            definition: {
              actions: {
                baseBlob: {
                  tierToCool: {
                    daysAfterModificationGreaterThan: 14
                  }
                  tierToArchive: {
                    daysAfterModificationGreaterThan: 32
                  }
                  delete: {
                    daysAfterModificationGreaterThan: 2563
                  }
                }
                snapshot: {
                  delete: {
                    daysAfterCreationGreaterThan: 32
                  }
                }
              }
              filters: {
                blobTypes: [
                  'blockBlob'
                ]
              }
            }
          }
          {
            enabled: true
            name: 'flowLogRetentionPolicy_2021-09-04 19:28:29.382'
            type: 'Lifecycle'
            definition: {
              actions: {
                baseBlob: {
                  delete: {
                    daysAfterModificationGreaterThan: 30
                  }
                }
              }
              filters: {
                blobTypes: [
                  'blockBlob'
                ]
                prefixMatch: [
                  'insights-logs-networksecuritygroupflowevent/resourceId=/SUBSCRIPTIONS/B62811C4-D18F-4CD9-8710-E9EE0D6B4ADA/RESOURCEGROUPS/T-TSTSP1-NETWORK/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/T-TSTSP1-NETWORK-VNET-MANAGEDINSTANCESUBNET-NSG'
                  'insights-logs-networksecuritygroupflowevent/resourceId=/SUBSCRIPTIONS/B62811C4-D18F-4CD9-8710-E9EE0D6B4ADA/RESOURCEGROUPS/T-TSTSP1-NETWORK/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/T-TSTSP1-NETWORK-VNET-FRONTENDSUBNET-NSG'
                ]
              }
            }
          }        
        ]
      }
    }
    
  }
}


// ::
// p-mgt-auto
//
// - res.arm.automation
// - res.arm.automation.diag

resource rgAuto 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: strRGAuto
  location: location
  tags: objResTags
}

module resAutomationAccount '../../modules/automation/automation.bicep' = {
  scope: resourceGroup(rgAuto.name)
  name: 'res.arm.automation'
  params: {
    tags: objResTags
    workspaceId: resWorkspace.outputs.id
  }
}


// ::
// p-mgt-mon
//
// - res.arm.workspace
// - res.arm.workspace.queries
// - res.arm.workspace.collectiontier
// - res.arm.scheduledqueryrules.critical
// - res.arm.scheduledqueryrules.error
// - res.arm.scheduledqueryrules.warning
// - res.arm.scheduledqueryrules.info
// - res.arm.actiongroup.critical
// - res.arm.actiongroup.error
// - res.arm.actiongroup.warning
// - res.arm.actiongroup.info

resource rgMon 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: strRGMon
  location: location
  tags: objResTags
}

module resWorkspace '../../modules/workspace/workspace.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace'
  params: {
    tags: objResTags
  }
}

module resWorkspaceSolutions '../../modules/workspace/solutions.bicep' = {
  name: 'res.arm.workspace.solutions'
  scope: resourceGroup(rgMon.name)
  params: {
    tags: objResTags
    workspaceId: resWorkspace.outputs.id
    solutions:  [
      'ChangeTracking'
      'AzureActivity'
      'InfrastructureInsights'
      'KeyVaultAnalytics'
      'ServiceMap'
      'Security'
      'Updates'
      'VMInsights'
    ]
  }
}

module resWorkspaceAutomation '../../modules/workspace/automation.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.automation'
  params: {
    workspaceId: resWorkspace.outputs.id
    automationId: resAutomationAccount.outputs.id
  }
}











