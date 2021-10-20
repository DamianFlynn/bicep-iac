targetScope = 'subscription'

//var tenantId = tenant().tenantId

var defaultTags = {
  ArchitectureName: 'vdc'
  ArchitectureVersion: '0.0.0.3'
  ConfigVersion: configVersion
}


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

param subMon string
param configVersion string = '0.0.0.1'


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
  name: 'res.management'
  scope: subscription(subMon)
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
