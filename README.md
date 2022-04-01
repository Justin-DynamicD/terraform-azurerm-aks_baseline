# aks_baseline

This module bundles together the recomendations outlined in the [Azure AKS baseline](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks) to result in a starting infrastructure that can be deployed easily.

Unlike the the complete topology example that includes the required hub-and-spoke network and log analytics in place, this module focuses soley on AKS and it's imediate recomended integrations.  Other modules exist that can help with the creation of the VNETs and subnets, so rather than repeat that effort, this module builds the following:

| | [AKS Secure Baseline](https://github.com/mspnp/aks-secure-baseline) | This Module |
|-----------------------------------------|-------|----------|
| Virtual Network hub-and-spoke           |  ✅   |    ❌    |
| Egress restriction using Azure Firewall |  ✅   |    ❌    |
| Fluxv2 integration*                     |  ✅   |    ❌    |
| Azure Networking CNI                    |  ✅   |    ✅    |
| Azure Active Directory Pod Identity     |  ✅   |    ✅    |
| Default Recomended Node config          |  ✅   |    ✅    |
| log retention rules                     |  ✅   |    ✅    |
| App Gateway/WAF                         |  ✅   |    ✅    |
| Keyvault secrets provider               |  ✅   |    ✅    |
| Azure Policy enabled                    |  ✅   |    ✅    |
| Managed public IP option                |  ❌   |    ✅    |

> Note: At this time `azurerm_kubernetes_cluster` does not have the ability to configure the Fluxv2 integration. This means the Traefik controller and other worklods that are normally deployed automatically as part of the bootsrap process in the example baseline doesn't occur in this module. The issue has been opened and [is being tracked here](https://github.com/hashicorp/terraform-provider-azurerm/issues/15011)

Each recomended integration is bundled into its own custom object block so it can be enabled/disabled as needed.  For example:

```yaml
module "aks" {
  source = "../"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = module.myvnet.vnet_subnets["aks_nodes"].id
  app_gateway = {
    enabled   = false
  }
  oms = {
    enabled   = true
    aks_logs  = {
      guard = true
    }
    storage_account_id = azurerm_storage_account.main.id
    workspace_id       = azurerm_log_analytics_workspace.main.id
  }
  zones = ["1", "2", "3"]
}
```

In this example, the integrated WAF is disabled, but OMS logging is enabled and a specific log toggled on.  While the Microsoft AKS baseline has all integrations enabled, the toggles allow for a bit more variance.

## Key Variable Blocks

### app_gateway

```yaml
app_gateway = {
    enabled      = false
    name         = ""
    public_ip_id = ""
    sku_capacity = "2"
    sku_name     = "WAF_v2"
    sku_tier     = "WAF_v2"
    subnet_id    = ""
  }
```

This block defines the WAF integration.  If `enabled` = true, the `subnet_id` becomes a required field, as AGW requires it's own dedicated subnet to provision into.

The module actually specifically defines the AGW and components as a seperate resource, so that if AKS is ever destroyed and rebuilt, provisioned public IPs remain until a value that forces similar action on the AGW occurs.

| name | type | required | default | description |
| --- | --- | --- | --- | --- |
| enabled | bool | no | false | enables creation of AGW |
| name | string | no | - | if specified, overrides the auto-generated name with this string |
| public_ip_id | string | no | - | if specified, instead of creating a public IP resource, will leverage the existing defined IP |
| sku_capacity | string | no | "2" | number of systems to deploy |
| sku_name | string | no | WAF_v2 | set subscription information |
| sku_tier | string | no | WAF_v2 | set subscription information |
| subnet_id | string | yes | "" | if agw is enabled, this is a required value to  determine the subnet to place the AGW in |

### node_default_pool

The node default pool refers to the system pool for AKS, following the recomended model of using 2 node pools to serperate system and user workloads.

> Note: the default VM size differs from the aks_baseline example. This model was chosen as it is cheaper (with the same cpu/memory) as well as supported under a free-tier Azure subscription which makes testing easier.

```yaml
node_default_pool = {
  enable_auto_scaling          = true
  max_count                    = 4
  min_count                    = 3
  name                         = "system"
  node_count                   = 3
  only_critical_addons_enabled = true
  os_disk_size_gb              = 70
  os_disk_type                 = "Ephemeral"
  vm_size                      = "Standard_D2ds_v5"
}
```

| name | type | required | default | description |
| --- | --- | --- | --- | --- |
| enable_auto_scaling | bool | no | true | enables auto-scaling |
| max_count | number | no | 4 | max number of nodes |
| min_count | number | no | 3 | minimum number of nodes |
| name | string | no | "system" | sets the name of the default node pool |
| node_count | number | no | 3 | sets the initial node count |
| only_critical_addons_enabled | bool | no | true | sets the node pool as type "system" restricting user workloads |
| os_disk_size_gb | number | no | 70 | size of node disks in GB |
| os_disk_type | string | no | "Ephemeral" | type of disk |
| vm_size | string | no | "Standard_D2ds_v5" | set the node type |

### node_user_pool

The node user pool refers to a dedicated pool for customer workloads, following the recomended model of using 2 node pools to serperate system and user workloads. Unlike the system pool, which is required, this pool can be disabled if desired to futher shrink the AKS footprint/cost.

> note: if `enabled = false`, be sure to set `only_critical_addons_enabled = false` in the default pool to ensure user workloads have a place to run.

```yaml
node_user_pool = {
  enable_auto_scaling = true
  enabled             = true
  eviction_policy     = "Delete"
  max_count           = 5
  min_count           = 2
  mode                = "User"
  name                = "user"
  node_count          = 2
  os_disk_size_gb     = 120
  os_disk_type        = "Ephemeral"
  priority            = "Regular"
  spot_max_price      = -1
  vm_size             = "Standard_D4ds_v5"
}
```

| name | type | required | default | description |
| --- | --- | --- | --- | --- |
| enable_auto_scaling | bool | no | true | enables auto-scaling |
| enable | bool | no | true | enable/disable this pool |
| eviction_policy | string | no | "Delete" | used with spot instances, set how nodes are eviced from the pool |
| max_count | number | no | 5 | max number of nodes |
| min_count | number | no | 2 | minimum number of nodes |
| mode | string | no | "User" | sets pool mode between User/System |
| name | string | no | "user" | sets the name of the node pool |
| node_count | number | no | 2 | sets the initial node count |
| os_disk_size_gb | number | no | 120 | size of node disks in GB |
| os_disk_type | string | no | "Ephemeral" | type of disk |
| priority | string | no | "Regular" | the type of nodes |
| spot_max_price | number | no | -1 | used with spot instances, set a price limit on server cost, -1 means no limit |
| vm_size | string | no | "Standard_D4ds_v5" | set the node type |

### oms

While log analytics and workspaces are beyond the reach of this module, it _does_ include the ability to configure the diagnostic logging for both the cluster and AGW (if exists).  All of the logs currently use the same `retention_days` setting.

```yaml
oms = {
  enabled            = false
  agw_logs           = {
    ApplicationGatewayAccessLog      = true
    ApplicationGatewayPerformanceLog = true
    ApplicationGatewayFirewallLog    = true
  }
  agw_metrics        = true
  aks_logs           = {
    cloud-controller-manager         = false
    csi-azuredisk-controller         = false
    csi-azurefile-controller         = false
    csi-snapshot-controller          = false
    kube-apiserver                   = true
    kube-audit                       = true
    kube-audit-admin                 = true
    kube-controller-manager          = true
    kube-scheduler                   = false
    cluster-autoscaler               = true
    guard                            = false
  }
  aks_metrics        = true
  retention_days     = 30
  storage_account_id = ""
  workspace_id       = ""
}
```

### tags

```yaml
tags = {
  Terraform = "true"
}
```

Map of tags to apply to every resource that is created.

## Outputs

Comming soon
