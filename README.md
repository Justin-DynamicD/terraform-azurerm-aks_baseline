# aks_baseline

This module bundles together the recomendations outlined in the [Azure AKS baseline](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks) to result in a starting infrastructure that can be deployed easily.

Unlike the the complete topology example that includes the required hub-and-spoke network and log analytics in place, this module focuses soley on AKS and it's imediate recomended integrations.  Other modules exist that can help with the creation of the VNETs and subnets, so rather than repeat that effort, this module builds the following:

| | [AKS Secure Baseline](https://github.com/mspnp/aks-secure-baseline) | This Module |
|-----------------------------------------|-------|----------|
| Virtual Network hub-and-spoke           |  ✅   |    ❌    |
| Egress restriction using Azure Firewall |  ✅   |    ❌    |
| Azure Networking CNI                    |  ✅   |    ✅    |
| Azure Active Directory Pod Identity     |  ✅   |    ✅    |
| Default Recomended Node config          |  ✅   |    ✅    |
| App Gateway/WAF                         |  ✅   |    ✅    |
| Keyvault secrets provider               |  ✅   |    ✅    |
| Azure Policy enabled                    |  ❌   |    ✅    |
| Managed public IP option                |  ❌   |    ✅    |
| log retention rules                     |  ❌   |    ✅    |

Each recomended integration is bundled into its own custom object block so it can be enabled/disabled as needed.  For example:

```yaml
module "aks" {
  source = "../"
  global_settings = {
    location            = azurerm_resource_group.test.location
    name_prefix         = "testaks"
    resource_group_name = azurerm_resource_group.test.name
  }
  aks = {
    os_disk_size_gb = 70
    subnet_id       = module.myvnet.vnet_subnets["aks_nodes"].id
    vm_size         = "Standard_D2ds_v5"
  }
  app_gateway = {
    enabled   = true
    subnet_id = module.myvnet.vnet_subnets["agw"].id
  }
  oms = {
    enabled = false
  }
  tags = {
    Project   = "AKS Baseline"
    CAF_Level = "3"
    Terraform = true
  }
  zones = ["1", "2", "3"]
}
```

In this example, the integrated WAF is enabled and added to the specified subnet,but OMS logging is disabled.  While the default aks baseline has all integrations enabled, for simplicity they are defautled to disabled to make the default deployment smaller.

## Variable Blocks

### global_settings

```yaml
global_settings = {
  location            = ""
  name_prefix         = ""
  resource_group_name = ""
}
```

| name | type | required | default | description |
| --- | --- | --- | --- | --- |
| location | string | yes | - | sets the region for all resources created |
| name_prefix | string | yes | - | if auto-generated names are used, this sets a unique prefix value |
| resource_group_name | string | yes | - | name of the resource group in which to place all created resources |

### aks

```yaml
aks = {
  automatic_channel_upgrade = ""
  azure_policy              = true
  docker_bridge_cidr        = "172.17.0.1/16"
  max_count                 = 3
  min_count                 = 1
  name                      = ""
  node_count                = 2
  os_disk_size_gb           = 128
  os_disk_type              = "Ephemeral"
  sku_tier                  = "Free"
  vm_size                   = "Standard_DS3_v2"
}
```

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

### oms

```yaml
oms = {
  enabled            = false
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
