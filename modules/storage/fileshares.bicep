var defaultTags = {
  ModuleName: 'storage.fileshare'
  ModuleVersion: '0.0.0.1'
}

@description('The resourceId of the Storage account we are adding the fileshares to.')
param storageAccountId string

@description('Tag resource with custom tags.')
param tags object = {}

@description('List of Fileshares to deploy to the Storage Account. Formatted as /n{/nname: "pmgtshell"/n  accessTier: "TransactionOptimized"/n  shareQuota: 5120/n  enabledProtocols: "SMB"/n}')
param fileShares object = {
  pmgtshell: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
}

/*
    {
      name: 'pmgtshell'
      @description('Access Tier for the specific share.GpV2 accounts can choose between TransactionOptimized (Default), Hot and Cool. FileStorage accounts can choose Premium')
      @allowed([
        'TransactionOptimized'
        'Premium'
        'Hot'
        'Cool'
      ])
      
      accessTier: 'TransactionOptimized'
      @description('The Storage Quota to allocate for the share')
      shareQuota: 5120
      
      @description('The authentication protocol that is used for the fileshare, can only be specified when creating a share')
      @allowed([
        'SMB'
        'NFS'
      ])
      
      enabledProtocols: 'SMB'
    } 
]
*/

// Standard Module Variables
var objResTags = union(defaultTags, tags)
var rgName = toLower(resourceGroup().name)


// Module Specific References
var strStorageAccountName = last(split(storageAccountId,'/'))


// Loop to Deploy Workspace Solutions
resource mainResources 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = [for item in items(fileShares): {
  name: '${strStorageAccountName}/default/${item.key}'
  properties: {
    accessTier: item.value.accessTier
    enabledProtocols: item.value.enabledProtocols
    shareQuota: item.value.shareQuota
  }
}]



output resources array = [for item in items(fileShares): {
  id: resourceId('Microsoft.Storage/storageAccounts/fileServices/shares', strStorageAccountName, 'default', item.key)
  name: item.key
}]
output resourceGroupName string = rgName
output tags object = objResTags
