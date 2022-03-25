######
# merge defaults to populate unassigned params
# and create complete local settings reference
######

locals {
  aks = defaults(var.aks, {
    automatic_channel_upgrade = ""
    azure_policy              = true
    docker_bridge_cidr        = "172.17.0.1/16"
    max_count                 = 4
    min_count                 = 3
    name                      = ""
    node_count                = 3
    os_disk_size_gb           = 70
    os_disk_type              = "Ephemeral"
    sku_tier                  = "Free"
    vm_size                   = "Standard_D2ds_v5"
  })
  app_gateway = defaults(var.app_gateway, {
    enabled      = false
    name         = ""
    public_ip_id = ""
    sku_capacity = "2"
    sku_name     = "WAF_v2"
    sku_tier     = "WAF_v2"
    subnet_id    = ""
  })
  global_settings = defaults(var.global_settings, {
    name_prefix = "aks-baseline"
  })
  # node_pools = defaults(var.node_pools, {
  #   {
  #     enable_auto_scaling       = true
  #     max_count                 = 4
  #     min_count                 = 3
  #     node_count                = 3
  #     os_disk_size_gb           = 70
  #     os_disk_type              = "Ephemeral"
  #     vm_size                   = "Standard_D2ds_v5"
  #   }
  # })
  oms = defaults(var.oms, {
    enabled            = false
    storage_account_id = ""
    workspace_id       = ""
  })

  # generate the resource names for everything based on the values offered
  names = {
    aks = coalesce(local.aks.name, "${local.global_settings.name_prefix}-aks")
    agw = coalesce(local.app_gateway.name, "${local.global_settings.name_prefix}-agw")
  }

  # these are unmodified, just dropped into locals for cconsistency
  acr_list        = var.acr_list
  tags            = var.tags
  zones           = var.zones
}
