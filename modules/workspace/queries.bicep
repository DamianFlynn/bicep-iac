var defaultTags = {
  ModuleName: 'workspace.queries'
  ModuleVersion: '0.0.0.1'
}

@description('The Log Analytics Workspace ID we are adding the solutions to.')
param workspaceId string

@description('List of Solutions to deploy to the Log Analytics Workspace.')
param queries array

@description('Tag resource with custom tags.')
param tags object = {}

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)


// Module Specific References
var strWorkspaceName = last(split(workspaceId,'/'))


// Loop to Deploy Workspace Solutions
resource workspaceName_savedQueries_name 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = [for item in queries: {
  name: '${strWorkspaceName}/${item.name}'

  properties: {
    displayName: item.displayName
    query: item.query
    category: item.category
  } //item.properties
}]



output resourceGroupName string = rgName
output resources array = [for item in queries: {
  id: resourceId('Microsoft.OperationalInsights/workspaces/savedSearches', strWorkspaceName, item.name)
  name: item.name
}]
output tags object = objResTags
