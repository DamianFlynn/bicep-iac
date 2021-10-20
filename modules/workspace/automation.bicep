var defaultTags = {
  ModuleName: 'workspace.automation'
  ModuleVersion: '0.0.0.1'
}

@description('The Log Analytics Workspace ID we are adding the solutions to.')
param workspaceId string

@description('The Azure Automation account Resource Id for the Log Analytics Workspace.')
param automationId string

@description('Tag resource with custom tags.')
param tags object = {}

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)



// Module Specific References
var strWorkspaceName = last(split(workspaceId,'/'))


// Link Automation to Workspace Solutions
resource resourceName_automation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' =  {
  name: '${strWorkspaceName}/automation'
  tags: objResTags
  properties: {
    resourceId: automationId
  }
}



output id string = resourceName_automation.id
output resourceGroupName string = rgName
output tags object = objResTags
