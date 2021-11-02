targetScope= 'managementGroup'

var defaultTags = {
  ArchitectureName: 'vdc'
  ArchitectureVersion: '0.0.0.3'
  ConfigVersion: configVersion
}

// Standard Architecture  Parameters

param configVersion string = '0.0.0.1'

@description('Define the Primary Location to Deploy the Architecture')
@allowed([
  'centralus'
  'eastasia'
  'southeastasia'
  'eastus'
  'eastus2'
  'westus'
  'westus2'
  'northcentralus'
  'southcentralus'
  'westcentralus'
  'northeurope'
  'westeurope'
  'japaneast'
  'japanwest'
  'brazilsouth'
  'australiasoutheast'
  'australiaeast'
  'westindia'
  'southindia'
  'centralindia'
  'canadacentral'
  'canadaeast'
  'uksouth'
  'ukwest'
  'koreacentral'
  'koreasouth'
  'francecentral'
  'southafricanorth'
  'uaenorth'
  'australiacentral'
  'switzerlandnorth'
  'germanywestcentral'
  'norwayeast'
  'jioindiawest'
  'westus3'
  'australiacentral2'
  ])
param location string = 'westeurope'

@description('Tag resource with custom tags.')
param tags object = {}

// Architecutre Specific Parameters (Defaults Recommended)

@description('Monitoring and Management Landing Zone Subscription ID')
param subscriptionIdMon string

@description('Address Prefix for the Virtual Hub')
param hubAddressPrefix string

@description('Virtual Router Atonimic System Number (ASN) for BGP peering')
param hubVirtualRouterAsn int

@description('Virtual Router assigned IP Addresses')
param hubVirtualRouterIps array


@description('Name of the Group which are to receive Error related mails')
param actionGroupForErrorsName string = 'Nobody'
@description('eMail Address of the Group which are to receive Error related mails')
param actionGroupForErrorsEmail string = 'email@blackhole.net'
@description('Name of the Group which are to receive Warning related mails')
param actionGroupForWarningsName string = 'Nobody'
@description('eMail Address of the Group which are to receive Warning related mails')
param actionGroupForWarningsEmail string = 'email@blackhole.net'
@description('Name of the Group which are to receive Critical related mails')
param actionGroupForCriticalName string = 'Nobody'
@description('eMail Address of the Group which are to receive Critical related mails')
param actionGroupForCriticalEmail string = 'email@blackhole.net'
@description('Name of the Group which are to receive Informational related mails')
param actionGroupForInfomationName string = 'Nobody'
@description('eMail Address of the Group which are to receive Informational related mails')
param actionGroupForInfomationEmail string = 'email@blackhole.net'

var objResTags = union(defaultTags, tags)

/*
resource mgGDC 'Microsoft.Management/managementGroups@2021-04-01' = {
  scope: tenantId
  name: 'gdc'
  properties: {
    details: {
      parent: {
        id: managementGroup('Tenant Root Group').id
      }
    }
  }
}
*/


// module deployed at subscription level but in a different subscription

module managementService '../../services/management/management.bicep' = {
  name: 'p.management'
  scope: subscription(subscriptionIdMon)
  params: {
    location: location
    tags: objResTags
    actionGroupForCriticalName: actionGroupForCriticalName
    actionGroupForCriticalEmail: actionGroupForCriticalEmail
    actionGroupForErrorsName: actionGroupForErrorsName
    actionGroupForErrorsEmail: actionGroupForErrorsEmail
    actionGroupForWarningsName: actionGroupForWarningsName
    actionGroupForWarningsEmail: actionGroupForWarningsEmail
    actionGroupForInfomationName: actionGroupForInfomationName
    actionGroupForInfomationEmail: actionGroupForInfomationEmail
  }
}



module vWanHub '../../services/NetworkHubs/vWanHub.bicep' = {
  scope: subscription(subscriptionIdMon)
  name: 'p.vwanhub'
  params: {
    location: location
    tags: objResTags
    resWorkspaceId: managementService.outputs.workspaceId
    addressPrefix: hubAddressPrefix
    virtualRouterAsn: hubVirtualRouterAsn
    virtualRouterIps: hubVirtualRouterIps
  }
}



module governance '../../services/management/policy.bicep' = {
  name: 'gov.policies'
  params: {
    actionGroupId: managementService.outputs.actionGroupErrorsId
    actionGroupRG: managementService.outputs.actionGroupErrorsRG
    actionGroupName: managementService.outputs.actionGroupErrorsName
    metricAlertResourceNamespace:	'Microsoft.Network/loadBalancers'
    metricAlertName:	'DipAvailability'
    metricAlertDimension1:	'ProtocolType'
    metricAlertDimension2:	'FrontendIPAddress'
    metricAlertDimension3:	'BackendIPAddress'
    metricAlertDescription:	'Average Load Balancer health probe status per time duration'
    metricAlertSeverity:	'2'
    metricAlertEnabled:	'true'
    metricAlertEvaluationFrequency:	'PT15M'
    metricAlertWindowSize:	'PT1H'
    metricAlertSensitivity:	'Medium'
    metricAlertOperator:	'LessThan'
    metricAlertTimeAggregation:	'Average'
    metricAlertCriterionType:	'DynamicThresholdCriterion'
    metricAlertAutoMitigate:	'true'
  }
}

/*
    resourceGroupName:	'BicepExampleRG'
    resourceGrouplocation:	'australiaeast'
    actionGroupEnabled:	true
    actionGroupShortName:	'bicepag'
    actionGroupEmailName:	'jloudon'
    actionGroupEmail:	'jesse.loudon@lab3.com.au'
    actionGroupAlertSchema:	true
    assignmentEnforcementMode:	'Default'
*/
