
az account set --subscription digi-management

az deployment sub create \
  --name vdcdeployment \
  --location westeurope \
  --template-file vdc.bicep \
  --parameters subMon=df56d048-2e20-4ab6-82b7-11643163aa53
   


{
  'location': 'westeu',
  'rgMon': 'p-mgt-mon'
  'subMon': 'df56d048-2e20-4ab6-82b7-11643163aa53' #'digi-management'
}