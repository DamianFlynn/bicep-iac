targetScope = 'managementGroup'


// Azure Automation Account

var defaultTags = {
  ModuleName: 'policy.definitions'
  ModuleVersion: '0.0.0.1'
}


// Standard Module Optional Parameters 

@description('Tag resource with custom tags.')
param tags object = {}

// Module Specific Optional Parameters


@description('The management group to host the policy definitions.')
param mgmtGroupId string

@description('List of Policy objects to create.')
param policies array

@description('The type of Policy Definitions. Values are NotSpecified, BuiltIn, Custom and Static.')
@allowed([
  'NotSpecified'
  'BuiltIn'
  'Custom'
  'Static'
])
param policyType string = 'Custom'

@description('The category for the Policy Definitions.')
param category string = 'Governance'




// Standard Module Variables
var objResTags = union(defaultTags, tags)




resource policyDefination 'Microsoft.Authorization/policyDefinitions@2019-09-01' = [for item in policies: if (!empty(policies)) {
  name: (empty(policies) ? 'dummy' : (contains(item, 'fullname') ? item.fullname : '${mgmtGroupId}-${item.name}'))
  properties: {
    displayName: (contains(item, 'displayname') ? item.displayName : (empty(policies) ? 'dummy' : (contains(item, 'fullname') ? item.fullname : '${mgmtGroupId}-${item.name}')))
    policyType: policyType
    description: (contains(item, 'description') ? item.description : '')
    metadata: {
      category: category
      tags: objResTags
    }
    mode: (contains(item, 'mode') ? item.mode : 'All')
    parameters: (contains(item, 'parameters') ? item.parameters : json('null'))
    policyRule: (contains(item, 'policyRule') ? item.policyRule : json('null'))
  }
}]

output policyDefinitions array = [for item in policies: {
  resourceId: resourceId('Microsoft.Authorization/policyDefinitions', (empty(policies) ? 'dummy' : (contains(item, 'fullname') ? item.fullname : '${mgmtGroupId}-${item.name}')))
  name: (empty(policies) ? 'dummy' : (contains(item, 'fullname') ? item.fullname : '${mgmtGroupId}-${item.name}'))
}]
output managementGroup string = mgmtGroupId
