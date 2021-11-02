targetScope= 'subscription'

var defaultTags = {
  ServiceName: 'vWan Hub'
  ServiceVersion: '0.0.0.1'
}

// Standard Service  Parameters

@description('Define the location to deploy the vWan Hub')
param location string

@description('Tag resource with custom tags.')
param tags object = {}

@description('Define the Log Analytics Workspace Id for diagnostic messages')
param resWorkspaceId string


// Service Specific Parameters (Defaults Recommended)

@description('Address Prefix for this virtual hub')
param addressPrefix string

@description('Virtual Router Atonimic System Number (ASN) for BGP peering')
param virtualRouterAsn int

@description('Virtual Router assigned IP Addresses')
param virtualRouterIps array

// Standard Service Variables
var objResTags = union(defaultTags, tags)


// ---=== subscription: p-net          ===---
//  --== resourceGroup: p-net-audit    ==--


// res.arm.eventsubscription.governance 
//
// Event Grid stream for all Subscription for All Resource Writes Sucessfully completed


//  --== resourceGroup: p-net-wan ==--
var strRGNetWan = 'p-net-wan'

resource rgNetWan 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: strRGNetWan
  location: location
  tags: objResTags
}

// res.arm.storage.diag
// Diagnostcs Storage account
//  Utilized by the VPN Gateway and Firewall

module resStorageDiag '../../modules/storage/main.bicep' = {
  scope: resourceGroup(rgNetWan.name)
  name: 'res.storage.diag'
  params: {
    sku: 'Standard_ZRS'
    kind: 'StorageV2'
    tags: objResTags
    purpose: 'vwandiag'
    workspaceId: resWorkspaceId
    networkACLBypass: 'AzureServices'
    networkACLDefaultAction: 'Allow'
  }
}

// res.arm.virtualwan

module resVirtualWan '../../modules/virtualwan/virtualwan.bicep' = {
  scope: resourceGroup(rgNetWan.name)
  name: 'res.virtualwan'
  params: {
    tags: objResTags
  }
}

// res.arm.virtualwan.vpnsite.tst
// res.arm.virtualhub

module resVirtualHub '../../modules/virtualhub/virtualhub.bicep' = {
  scope: resourceGroup(rgNetWan.name)
  name: 'res.virtualhub' 
  params: {
    tags: objResTags
    addressPrefix: addressPrefix
    virtualRouterAsn: virtualRouterAsn
    virtualRouterIps: virtualRouterIps 
    virtualWanId: resVirtualWan.outputs.id
  }
}

// res.arm.virtualhub.hubroutetables





module resVirtualHubRouteTableDefault '../../modules/virtualhub/routetable.bicep' = {
  scope: resourceGroup(rgNetWan.name)
  name: 'res.virtualhub.hubroutetable'
  params: {
    routeTableName: 'defaultRouteTable'
    routes: [
      {
        name: 'all_traffic'
        destinationType: 'CIDR'
        destinations: [
          regionaladdressspace
        ]
        nextHopType: 'ResourceId'
        nextHop: firewall.outputs.id
      }
    ]
    labels: [
      'default'
    ]
  }
}



module resVirtualHubRouteTablevNet '../../modules/virtualhub/routetable.bicep' = {
  scope: resourceGroup(rgNetWan.name)
  name: 'res.virtualhub.hubroutetable'
  params: {
    routeTableName: 'vNetRouteTable'
    routes: [
      {
        name: 'toFirewall'
        destinationType: 'CIDR'
        destinations: [
          '0.0.0.0/0'
        ]
        nextHopType: 'ResourceId'
        nextHop: firewall.outputs.id
      }
    ]
    labels: [
      'vnet'
    ]
  }
}

// res.arm.virtualhub.vpngateway
// res.arm.virtualhub.firewall

//  --== resourceGroup: p-net-azfw ==--

// res.arm.firewallpolicy.parent

//  --== resourceGroup: p-net-kv ==--

// res.arm.keyvault
// res.arm.keyvault.secrets.net


// ---=== subscription: p-gov          ===---
//  --== resourceGroup: p-gov-log ==--

// res.arm.storage.audit

//  --== resourceGroup: p-gov-cng ==--

// res.arm.appservices.app.func.concierge

// --== p-mgt-mon ==--

// res.arm.workspace

// --== p-we1net-audit ==--

// res.arm.eventsubscription.governance

// --== p-we1net-network ==--

// res.arm.firewallpolicy.child
// res.arm.networkwatcher

// --== datacenter.001 tonprem network ==--

// res.arm.publicipaddress
