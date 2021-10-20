var defaultTags = {
  ModuleName: 'actiongroup'
  ModuleVersion: '0.0.0.1'
}

// Parameters for the Module

@description('Override standard resource name / governance naming standard.')
param name string = ''


@description('Tag resource with custom tags.')
param tags object = {}

@description('The purpose of the Action Group. Will be part of the name.')
param purpose string = ''

@description('Indicates whether this action group is enabled.')
param enabled bool = true

@description('The list of email receivers that are part of this action group.')
param emailReceivers array = []

@description('The list of SMS receivers that are part of this action group.')
param smsReceivers array = []

@description('The list of webhook receivers that are part of this action group.')
param webhookReceivers array = []

@description('The list of ITSM receivers that are part of this action group.')
param itsmReceivers array = []

@description('The list of AzureAppPush receivers that are part of this action group.')
param azureAppPushReceivers array = []

@description('The list of AutomationRunbook receivers that are part of this action group.')
param automationRunbookReceivers array = []

@description('The list of voice receivers that are part of this action group.')
param voiceReceivers array = []

@description('The list of logic app receivers that are part of this action group.')
param logicAppReceivers array = []

@description('The list of azure function receivers that are part of this action group.')
param azureFunctionReceivers array = []

@description('The list of ARM role receivers that are part of this action group.')
param armRoleReceivers array = []



// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)

// Governance Naming Standard
var nameLength = 50
var nameSuffix = '-ag'
var suffix = (((!empty(name)) || endsWith(purpose, nameSuffix)) ? '' : nameSuffix)
var prefix = (empty(purpose) ? rgName : (startsWith(purpose, rgName) ? purpose : '${rgName}-${purpose}'))
var mainResourceName = '${take((empty(name) ? prefix : name), (nameLength - length(suffix)))}${suffix}'
var groupShortName = take(replace(replace(mainResourceName, ' ', ''), '-', ''), 12)



resource actiongroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: mainResourceName
  location: 'global'
  tags: objResTags
  properties: {
    groupShortName: groupShortName
    enabled: enabled
    emailReceivers: (empty(emailReceivers) ? json('null') : emailReceivers)
    smsReceivers: (empty(smsReceivers) ? json('null') : smsReceivers)
    webhookReceivers: (empty(webhookReceivers) ? json('null') : webhookReceivers)
    itsmReceivers: (empty(itsmReceivers) ? json('null') : itsmReceivers)
    azureAppPushReceivers: (empty(azureAppPushReceivers) ? json('null') : azureAppPushReceivers)
    automationRunbookReceivers: (empty(automationRunbookReceivers) ? json('null') : automationRunbookReceivers)
    voiceReceivers: (empty(voiceReceivers) ? json('null') : voiceReceivers)
    logicAppReceivers: (empty(logicAppReceivers) ? json('null') : logicAppReceivers)
    azureFunctionReceivers: (empty(azureFunctionReceivers) ? json('null') : azureFunctionReceivers)
    armRoleReceivers: (empty(armRoleReceivers) ? json('null') : armRoleReceivers)
  }
}

output id string = actiongroup.id
output name string = mainResourceName
output actionGroupId string = actiongroup.id
output actionGroupName string = mainResourceName
output resourceGroupName string = rgName
output tags object = objResTags
