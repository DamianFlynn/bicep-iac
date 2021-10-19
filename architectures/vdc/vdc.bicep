targetScope = 'subscription'

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

var objResTags = union(defaultTags, tags)

// module deployed at subscription level but in a different subscription
module managementService '../../services/management/management.bicep' = {
  name: 'res.management'
  scope: subscription(subMon)
  params: {
    location: location
    tags: objResTags
  }
}
