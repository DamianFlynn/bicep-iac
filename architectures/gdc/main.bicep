targetScope= 'managementGroup'

param subscriptionID string = 'df56d048-2e20-4ab6-82b7-11643163aa53'
param resourceGroupName string = 'poc-resourceGroup'


// module deployed at tenant level
module tenantModule 'tenant.module.bicep' = {
  name: 'deployToTenant'
  scope: tenant()
}
/*
// module deployed to subscription in the management group
module subscriptionModule 'subscription.module.bicep' = {
  name: 'deployToSub'
  scope: subscription(subscriptionID)
}

// module deployed to resource group in the management group
module resourcesModule 'resources.module.bicep' = {
  name: 'deployToRG'
  scope: resourceGroup(subscriptionID, resourceGroupName)
}
*/
