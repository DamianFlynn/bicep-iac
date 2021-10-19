var defaultTags = {
  ModuleName: 'workspace.solutions'
  ModuleVersion: '0.0.0.1'
}

@description('The Log Analytics Workspace ID we are adding the solutions to.')
param workspaceId string

@description('List of Solutions to deploy to the Log Analytics Workspace.')
param solutions array

@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)
var rgLocation = (empty(location) ? resourceGroup().location : location)


// Module Specific References
var strWorkspaceName = last(split(workspaceId,'/'))


// Loop to Deploy Workspace Solutions

resource mainResources 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for item in solutions: {
  name: '${item}(${strWorkspaceName})'
  location: rgLocation
  tags: objResTags
  plan: {
    name: '${item}(${strWorkspaceName})'
    product: 'OMSGallery/${item}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspaceId
  }
}]


output resources array = [for item in solutions: {
  id: resourceId('Microsoft.OperationsManagement/solutions', item)
  name: item
}]
output resourceGroupName string = rgName
