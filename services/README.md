# Services

This is the main building block of a solution, for example it may define a business service which is to be delivered in an environment, eg; Active Directory Domain Controllers, Azure Data Factory, Azure Virtual Desktop, Imaging Building, Radius, etc.

The service is build on Modules, and focuses on the distribution of the relevant resources to various landing zones, which typically (but not always) will be confined to a single subscription, and span multiple resource groups. 

The service definition will include the settings required for the service to operated under best practices, including as an example Managed Identities, Hierarchical Storage Management Lifecycle, Monitoring Alerts, Policies, Queries, etc.

Services will be established by referencing modules, and establishing the logic required to integrate these modules. 

