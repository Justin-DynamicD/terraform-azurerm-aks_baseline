######
# merge defaults to populate unassigned params
# and create complete local settings reference
######

locals {
  defaults = {
    global_settings   = {
      environment         = "dev",
      location            = "West US 2"
      name_prefix         = "devops"
      resource_group_name = "sample"
    }
    network = {
      agw_subnet_id = ""
      agw_address_prefix = ""
      aks_subnet_id = ""
      zones = []
    }
    app_gateway = {
      sku_name = "WAF_v2"
      sku_tier = "WAF_v2"
      sku_capacity = "2"
      private_ip_suffix = "10"
    }
    oms = {}
    aks = {
      sku_tier                  = "Free"
      automatic_channel_upgrade = null
      node_count                = 2
      min_count                 = 1
      max_count                 = 3
      vm_size                   = "Standard_DS3_v2"
      os_disk_size_gb           = 128
      os_disk_type              = "Ephemeral"
      docker_bridge_cidr        = "172.17.0.1/16"
      azure_policy              = "true"
    }
    acr_list = {}
    tags     = {}
  }
  
  global_settings   = merge(local.defaults.global_settings, var.global_settings)
  network           = merge(local.defaults.network, var.network)
  app_gateway       = merge(local.defaults.app_gateway, var.app_gateway)
  aks               = merge(local.defaults.aks, var.aks)
  oms               = merge(local.defaults.oms, var.oms)
  acr_list          = merge(local.defaults.acr_list, var.acr_list)
  tags              = merge(local.defaults.tags, { "Environment" = local.global_settings.environment }, var.tags)
}
