######
# merge defaults to populate unassigned params
# and create complete local settings reference
######

locals {
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
