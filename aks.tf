# see locals block for hardcoded names.
resource "azurerm_kubernetes_cluster" "main" {
  lifecycle {
    # due to auto-scaling we need to ignore the nodecount after launch
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  name                             = "${local.global_settings.name_prefix}-${local.global_settings.environment}-aks"
  location                         = local.global_settings.location
  dns_prefix                       = "${local.global_settings.name_prefix}${local.global_settings.environment}aks"
  resource_group_name              = data.azurerm_resource_group.source.name
  sku_tier                         = local.aks.sku_tier
  automatic_channel_upgrade        = local.aks.automatic_channel_upgrade
  azure_policy_enabled             = local.aks.azure_policy
  http_application_routing_enabled = false
  ingress_application_gateway {
    gateway_id                     = azurerm_application_gateway.main.id
  }
  dynamic "oms_agent" {
    for_each = local.oms != {} ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id   = local.oms.workspace_id
    }
  }
  
  role_based_access_control_enabled = true

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    node_count          = local.aks.node_count
    min_count           = local.aks.min_count
    max_count           = local.aks.max_count
    vm_size             = local.aks.vm_size
    os_disk_size_gb     = local.aks.os_disk_size_gb
    os_disk_type        = local.aks.os_disk_type
    vnet_subnet_id      = local.network.aks_subnet_id
    availability_zones  = local.network.zones != [] ? local.network.zones : null
    tags                = local.tags
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.main.id
  }

  network_profile {
    network_plugin     = "azure"
  }

  tags = local.tags
  depends_on = [
    azurerm_role_assignment.agw,
    azurerm_role_assignment.agwrg
  ]
}