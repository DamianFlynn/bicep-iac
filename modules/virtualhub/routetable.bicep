var defaultTags = {
  ModuleName: 'vhub.routetable'
  ModuleVersion: '0.0.0.1'
}

// Standard Module Parameters


// Module Specific Parameters (Defaults Recommended)

@description('The Resource Id of the Virtual Hub.')
param virtualHubId string

@description('')
param routeTableName string

@description('Virtual Hub Route Table  {/n  addressPrefixes: []/n  nextHopIpAddress: []/n}')
param routes object

@description('List of labels to associate with the route table')
param labels array

// Standard Module Variables
var rgName = toLower(resourceGroup().name)

// Specific Module Variables
var hubName = last(split(virtualHubId, '/'))


// Azure Resource Creation
resource hubRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-11-01' = {
  name: '${hubName}/${routeTableName}'
  properties:{
     labels: labels
     routes: routes.routes
  }
}



output id string = hubRouteTable.id
output name string = hubRouteTable.name
output resourceGroupName string = rgName
