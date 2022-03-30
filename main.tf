######
# merge defaults to populate unassigned params
# and create complete local settings reference
######

locals {
  # weird behavior with complex merge types, so to clean it up I make a default value then merge,
  # thus ignoring the defaults function that accepts null values
  defaults = {
    agw_logs  = {
      ApplicationGatewayAccessLog      = true
      ApplicationGatewayPerformanceLog = true
      ApplicationGatewayFirewallLog    = true
    }
    aks_logs  = {
      cloud-controller-manager         = false
      cluster-autoscaler               = true
      csi-azuredisk-controller         = false
      csi-azurefile-controller         = false
      csi-snapshot-controller          = false
      guard                            = false
      kube-apiserver                   = true
      kube-audit                       = true
      kube-audit-admin                 = true
      kube-controller-manager          = true
      kube-scheduler                   = false
    }
  }
  # here we iterate over the optional fields that pass as null and remove them
  clean_agw_logs = var.oms.agw_logs != null ? { for k, v in var.oms.agw_logs : k => v if v != null } : {}
  clean_aks_logs = var.oms.aks_logs != null ? { for k, v in var.oms.aks_logs : k => v if v != null } : {}

  # now we store these merged values for use.
  merged_objects = {
    agw_logs  = merge(local.defaults.agw_logs, local.clean_agw_logs)
    aks_logs  = merge(local.defaults.aks_logs, local.clean_aks_logs)
  }

  # regular defaults below
  app_gateway = defaults(var.app_gateway, {
    enabled      = false
    name         = ""
    public_ip_id = ""
    sku_capacity = "2"
    sku_name     = "WAF_v2"
    sku_tier     = "WAF_v2"
    subnet_id    = ""
  })
  node_default_pool = defaults(var.node_default_pool, {
    enable_auto_scaling          = true
    max_count                    = 4
    min_count                    = 3
    name                         = "system"
    node_count                   = 3
    only_critical_addons_enabled = true
    os_disk_size_gb              = 70
    os_disk_type                 = "Ephemeral"
    vm_size                      = "Standard_D2ds_v5"
  })
  node_user_pool = defaults(var.node_user_pool, {
    enabled             = true
    enable_auto_scaling = true
    max_count           = 5
    min_count           = 2
    mode                = "User"
    name                = "user"
    node_count          = 2
    os_disk_size_gb     = 120
    os_disk_type        = "Ephemeral"
    priority            = "Regular"
    eviction_policy     = "Delete"
    spot_max_price      = -1
    vm_size             = "Standard_D4ds_v5"
  })
  oms = defaults(var.oms, {
    enabled            = false
    # these sub-attributes don't apply properly, so while the values are here, they are useless
    # until behavior is patched/refactored
    # https://github.com/hashicorp/terraform/issues/28406
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
  })

  # generate the resource names for everything based on the values offered
  names = {
    aks = coalesce(var.name, "${var.name_prefix}-aks")
    agw = coalesce(local.app_gateway.name, "${var.name_prefix}-agw")
  }

  # these are unmodified, just dropped into locals for cconsistency
  acr_list                  = var.acr_list
  automatic_channel_upgrade = var.automatic_channel_upgrade
  azure_policy              = var.azure_policy
  docker_bridge_cidr        = var.docker_bridge_cidr
  location                  = var.location
  resource_group_name       = var.resource_group_name
  sku_tier                  = var.sku_tier
  subnet_id                 = var.subnet_id
  tags                      = var.tags
  zones                     = var.zones
}
