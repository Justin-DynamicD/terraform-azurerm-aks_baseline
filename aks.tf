# see locals block for hardcoded names.
resource "azurerm_kubernetes_cluster" "main" {
  lifecycle {
    # due to auto-scaling we need to ignore the nodecount after launch
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  name                              = local.names.aks
  location                          = local.global_settings.location
  dns_prefix                        = replace(local.names.aks, "-", "")
  resource_group_name               = data.azurerm_resource_group.source.name
  sku_tier                          = local.aks.sku_tier
  automatic_channel_upgrade         = local.aks.automatic_channel_upgrade != "" ? local.aks.automatic_channel_upgrade : null
  azure_policy_enabled              = local.aks.azure_policy
  http_application_routing_enabled  = false
  role_based_access_control_enabled = true
  dynamic "ingress_application_gateway" {
    for_each = local.app_gateway.enabled == true ? ["ingress_application_gateway"] : []
    content {
      gateway_id                    = azurerm_application_gateway.main[0].id
    }
  }
  key_vault_secrets_provider {
    secret_rotation_enabled  = false
  }
  dynamic "oms_agent" {
    for_each = local.oms.enabled == true ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id   = local.oms.workspace_id
    }
  }
  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    node_count          = local.aks.node_count
    min_count           = local.aks.min_count
    max_count           = local.aks.max_count
    vm_size             = local.aks.vm_size
    os_disk_size_gb     = local.aks.os_disk_size_gb
    os_disk_type        = local.aks.os_disk_type
    vnet_subnet_id      = local.aks.subnet_id
    zones               = local.zones != [] ? local.zones : null
    tags                = local.tags
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }
  network_profile {
    network_plugin     = "azure"
  }
  tags = local.tags
}