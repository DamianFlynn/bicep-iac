var defaultTags = {
  ModuleName: 'workbooks'
  ModuleVersion: '0.0.0.1'
}


@description('Override inheritance of resource group location with specified Azure region.')
param location string = ''

@description('Tag resource with custom tags.')
param tags object = {}

//

@description('The kind of Workbook.')
@allowed([
  'shared'
  'user'
])
param kind string = 'shared'

@description('Customer Managed Identity.')
param identity object = {
  type: 'None'
}

@description('List of Workbooks.')
param workbooks array


// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgLocation = (empty(location) ? resourceGroup().location : location)
var rgName = toLower(resourceGroup().name)


resource mainResources 'microsoft.insights/workbooks@2021-03-08' = [for item in workbooks: {
  name: guid(item.name)
  location: rgLocation
  tags: objResTags
  kind: kind
  identity: identity
  properties:  {
    serializedData: item.serializedData
    displayName: item.name
    category: item.category
    version: 'Notebook/1.0'
    sourceId: item.sourceId
  }//  item.properties
}]


output resources array = [for item in workbooks: {
  id: resourceId('microsoft.insights/workbooks', item.name)
  name: item.name
}]
output resourceGroupName string = rgName
output tags object = objResTags
