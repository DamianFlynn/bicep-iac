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
var strRGMgtShl = 'p-mgt-shl'


// Establish Subscription Diagnostics
module subscriptionDiagnostics '../../modules/subscription/diagnostics.bicep' = {
  scope: subscription()
  name: 'sub.mgt.diagnostics'
  params: {
    tags: objResTags
    workspaceId: resWorkspace.outputs.id
    storageId: resStorageAudit.outputs.id
  }
}

module diag '../../modules/subscription/diagnostics.bicep' = {
  name: 'testing'
  params: {
    workspaceId: resWorkspace.outputs.id
    storageId: resStorageAudit.outputs.id
  }
}

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
                prefixMatch: [
                ]
              }
            }
          }        
        ]
      }
    }
    networkACLBypass: 'AzureServices'
    networkACLDefaultAction: 'Allow'
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
    storageId: resStorageAudit.outputs.id
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

@description('Name of the Group which are to receive Error related mails')
param actionGroupForErrorsName string
@description('eMail Address of the Group which are to receive Error related mails')
param actionGroupForErrorsEmail string
@description('Name of the Group which are to receive Warning related mails')
param actionGroupForWarningsName string
@description('eMail Address of the Group which are to receive Warning related mails')
param actionGroupForWarningsEmail string
@description('Name of the Group which are to receive Critical related mails')
param actionGroupForCriticalName string
@description('eMail Address of the Group which are to receive Critical related mails')
param actionGroupForCriticalEmail string
@description('Name of the Group which are to receive Informational related mails')
param actionGroupForInfomationName string
@description('eMail Address of the Group which are to receive Informational related mails')
param actionGroupForInfomationEmail string


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

output workspaceId string = resWorkspace.outputs.id

module resWorkspaceAutomation '../../modules/workspace/automation.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.automation'
  params: {
    workspaceId: resWorkspace.outputs.id
    automationId: resAutomationAccount.outputs.id
  }
}



module resWorkspaceQueries '../../modules/workspace/queries.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.queries'
  params: {
    queries: [
//      json(loadTextContent('./kqlQueries/AzureFirewall Traffic from Source IP.json'))
//      json(loadTextContent('./kqlQueries/AzureFirewall Traffic to Destination IP.json'))
//      json(loadTextContent('./kqlQueries/Backups IaaS VM Jobs.json'))
//      json(loadTextContent('./kqlQueries/Heartbeats Reported Solutions.json'))
//      json(loadTextContent('./kqlQueries/Network BGP Received Routes.json'))
//      json(loadTextContent('./kqlQueries/NetworkAnalytics Flows from Source IP.json'))
//      json(loadTextContent('./kqlQueries/NetworkAnalytics Traffic to Destination IP.json'))
//      json(loadTextContent('./kqlQueries/VirtualMachine Windows.json'))
//      json(loadTextContent('./kqlQueries/VirtualMachine Linux.json'))
//      json(loadTextContent('./kqlQueries/WAF Traffic Blocked.json'))
//      json(loadTextContent('./kqlQueries/WAF Traffic With Warnings.json'))
    ] 
    workspaceId: resWorkspace.outputs.id
  }
}


module actionGroupErrors '../../modules/actiongroup/actiongroup.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.actionGroupQuery.Errors'
  params: {
    tags: objResTags
    enabled: true
    purpose: 'ops-error'
    emailReceivers: [
      {
        'name': actionGroupForErrorsName
        'emailAddress': actionGroupForErrorsEmail
        'useCommonAlertSchema': true
      }
    ]
    armRoleReceivers: [
      {
        'roleId': '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        'useCommonAlertSchema': true
        'name': 'Monitoring Contributor'
      }
      {
        'roleId': '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        'useCommonAlertSchema': true
        'name': 'Monitoring Reader'
      }
    ]
  }
}

output actionGroupErrorsName string = actionGroupErrors.outputs.name
output actionGroupErrorsId string = actionGroupErrors.outputs.id
output actionGroupErrorsRG string = actionGroupErrors.outputs.resourceGroupName


module resWorkspaceScheduledQueryErrors '../../modules/scheduledqueryrules/scheduledqueryrules.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.ScheduledQuery.Errors'
  params: {
    workspaceId: resWorkspace.outputs.id
    actionGroupId: actionGroupErrors.outputs.id
    tags: objResTags
    rules: [
      json(replace(loadTextContent('./scheduledQueryRules/Azure Service Issue (Error).json'), '{{workspaceResourceId}}', resWorkspace.outputs.id))
    ]
  }
}

module actionGroupCritical '../../modules/actiongroup/actiongroup.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.actionGroupQuery.Critical'
  params: {
    tags: objResTags
    enabled: true
    purpose: 'ops-critical'
    emailReceivers: [
      {
        'name': actionGroupForCriticalName
        'emailAddress': actionGroupForCriticalEmail
        'useCommonAlertSchema': true
      }
    ]
    armRoleReceivers: [
      {
        'roleId': '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        'useCommonAlertSchema': true
        'name': 'Monitoring Contributor'
      }
      {
        'roleId': '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        'useCommonAlertSchema': true
        'name': 'Monitoring Reader'
      }
    ]
  }
}

module resWorkspaceScheduledQueryCritical '../../modules/scheduledqueryrules/scheduledqueryrules.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.ScheduledQuery.Critical'
  params: {
    workspaceId: resWorkspace.outputs.id
    actionGroupId: actionGroupCritical.outputs.id
    tags: objResTags
    rules: [
      json(loadTextContent('./scheduledQueryRules/Azure Policy is not compliant (Audit).json'))
      json(loadTextContent('./scheduledQueryRules/Azure Resource is not available.json'))
      json(replace(loadTextContent('./scheduledQueryRules/Azure Service Issue (Critical).json'), '{{workspaceResourceId}}', resWorkspace.outputs.id))
    ]
  }
}

module actionGroupWarning '../../modules/actiongroup/actiongroup.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.actionGroupQuery.Warnings'
  params: {
    tags: objResTags
    enabled: true
    purpose: 'ops-warning'
    emailReceivers: [
      {
        'name': actionGroupForWarningsName
        'emailAddress': actionGroupForWarningsEmail
        'useCommonAlertSchema': true
      }
    ]
    armRoleReceivers: [
      {
        'roleId': '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        'useCommonAlertSchema': true
        'name': 'Monitoring Contributor'
      }
      {
        'roleId': '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        'useCommonAlertSchema': true
        'name': 'Monitoring Reader'
      }
    ]
  }
}

module resWorkspaceScheduledQueryWarnings '../../modules/scheduledqueryrules/scheduledqueryrules.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.ScheduledQuery.Warnings'
  params: {
    workspaceId: resWorkspace.outputs.id
    actionGroupId: actionGroupWarning.outputs.id
    tags: objResTags
    rules: [
      json(loadTextContent('./scheduledQueryRules/Azure Resource is Degraded.json'))
      json(loadTextContent('./scheduledQueryRules/Azure Resource Status Unknown.json'))
      json(loadTextContent('./scheduledQueryRules/Azure Service Issue (Warning).json'))
      json(loadTextContent('./scheduledQueryRules/Azure Emergency Maintenance.json'))
      json(loadTextContent('./scheduledQueryRules/Azure Security Advisory (Action Required).json'))
      
    ]
  }
}

module actionGroupInfo '../../modules/actiongroup/actiongroup.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.actionGroupQuery.Info'
  params: {
    tags: objResTags
    enabled: true
    purpose: 'ops-info'
    emailReceivers: [
      {
        'name': actionGroupForInfomationName
        'emailAddress': actionGroupForInfomationEmail
        'useCommonAlertSchema': true
      }
    ]
  }
}


module resWorkspaceScheduledQueryInfo '../../modules/scheduledqueryrules/scheduledqueryrules.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workspace.ScheduledQuery.Info'
  params: {
    workspaceId: resWorkspace.outputs.id
    actionGroupId: actionGroupInfo.outputs.id
    tags: objResTags
    rules: [
      json(loadTextContent('./scheduledQueryRules/Azure Service Issue (Informational).json'))
      json(loadTextContent('./scheduledQueryRules/Azure Standard Planned Maintenance.json'))
      json(loadTextContent('./scheduledQueryRules/Azure Security Advisory (Informational).json'))
      json(loadTextContent('./scheduledQueryRules/Azure Health Advisory (Action Required).json'))
      json(loadTextContent('./scheduledQueryRules/Azure Health Advisory (Informational).json'))
      json(loadTextContent('./scheduledQueryRules/Azure Recommendation.json'))
    ]
  }
}


module resWorkbooks '../../modules/workbooks/workbooks.bicep' = {
  scope: resourceGroup(rgMon.name)
  name: 'res.arm.workbooks'
  params: {
    workbooks: [
      {
        name: 'Azure Network Overview'
        category: 'Workbooks'
        sourceId: 'Azure Firewall'
        serializedData: loadTextContent('./workbooks/Azure Network.json')
        version: 'Notebook/1.0'
      }
      {
        name: 'Azure VDC Overview'
        category: 'Workbooks'
        sourceId: 'Overview'
        serializedData: loadTextContent('./workbooks/VDC Overview.json')
        version: 'Notebook/1.0'
      }
      //json(loadTextContent('./workbooks/Azure Firewall.json'))
      //json(loadTextContent('./workbooks/Azure Inventory.json'))
      //json(loadTextContent('./workbooks/Azure Backup Report.json'))
      
      //json()
      //json(loadTextContent('./workbooks/Virtual Machine Health.json'))
      //json(loadTextContent('./workbooks/VM Updates.json'))
    ]
  }
}

// ::
// p-mgt-shl
//
// - res.arm.storage.shelll

resource rgMgtShl 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: strRGMgtShl
  location: location
  tags: objResTags
}

module resStorageMgtShl '../../modules/storage/main.bicep' = {
  scope: resourceGroup(rgMgtShl.name)
  name: 'res.arm.storage.mgt.shell'
  params: {
    sku: 'Standard_ZRS'
    kind: 'StorageV2'
    tags: objResTags
    purpose: 'data'
    workspaceId: resWorkspace.outputs.id
    networkACLBypass: 'AzureServices'
    networkACLDefaultAction: 'Allow'
  }
}

module resStorageMgtShlFileshare '../../modules/storage/fileshares.bicep' = {
  name: 'storage_p_mgt_shl_fileshare_pmgtshell'
  scope: resourceGroup('p-mgt-shl')
  params: {
    storageAccountId: resStorageMgtShl.outputs.id
    fileShares: {
      pmgtshell: {
        accessTier: 'TransactionOptimized'
        shareQuota: 5120
        enabledProtocols: 'SMB'
      }
    }
  }
}


output tags object = objResTags

