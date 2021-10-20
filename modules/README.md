# Modules

A module encapsulates one or more native resources to implement a resources which embraces all the best practices of governance and architecture.

Modules will offer customization of its final implementation, however these will always be considered as optional, resulting in the default instantiation delivering a production ready set of resources.

Optional parameter's will also act as enablement switches; for example a Module for a Virtual Machine should expose the option to provide the resource ID of an Azure Log Analytics workspace; if this is provided the module will proceed to complete the scaffolding of the service with best practice monitoring enabled

For example 