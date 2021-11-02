var defaultTags = {
  ModuleName: 'vwan'
  ModuleVersion: '0.0.0.1'
}

// Standard Module Parameters

@description('Override standard resource name / governance naming standard.')
param name string = ''

@description('The purpose of the resource. Will be part of the name.')
param purpose string = ''

@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}



// Module Specific Parameters (Defaults Recommended)

@description('VPN Encryption to be disabled or not')
param disableVpnEncryption bool = false

@description('True if branch to brach traffic is allowed')
param allowBranchToBranchTraffic bool = true

@description('True if Vnet to Vnet traffic is allowed')
param allowVnetToVnetTraffic bool = true

@description('The type of the VWan')
param type string = 'Standard'



// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)


// Governance Naming Standard
var nameLength = 80
var nameSuffix = '-vwan'
var suffix = (((!empty(name)) || endsWith(purpose, nameSuffix)) ? '' : nameSuffix)
var prefix = take((empty(name) ? (startsWith(purpose, rgName) ? '${purpose}' : empty(purpose) ? '${rgName}' : '${rgName}-${purpose}') : name), (nameLength - length(suffix)))
var mainResourceName = '${prefix}${suffix}'


// Azure Resource Creation


// Create Log Analytics Workspace
resource mainResource 'Microsoft.Network/virtualWans@2021-03-01' = {
  name: mainResourceName
  location: rgLocation
  tags: objResTags
  properties: {
    disableVpnEncryption: disableVpnEncryption
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    type: type
  }
}



output id string = mainResource.id
output name string = mainResourceName
output vwanId string = mainResource.id
output vwanName string = mainResourceName
output resourceGroupName string = rgName
output tags object = objResTags
