resource "azurerm_kubernetes_cluster" "main" {
  lifecycle {
    # due to auto-scaling we need to ignore the nodecount after launch
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  name                              = local.names.aks
  location                          = local.location
  dns_prefix                        = replace(local.names.aks, "-", "")
  resource_group_name               = data.azurerm_resource_group.source.name
  sku_tier                          = local.sku_tier
  automatic_upgrade_channel         = local.automatic_upgrade_channel != "none" ? local.automatic_upgrade_channel : null
  azure_policy_enabled              = local.azure_policy
  http_application_routing_enabled  = false
  role_based_access_control_enabled = true
  dynamic "ingress_application_gateway" {
    for_each = local.app_gateway.enabled == true ? ["ingress_application_gateway"] : []
    content {
      gateway_id = azurerm_application_gateway.main[0].id
    }
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }
  dynamic "oms_agent" {
    for_each = local.oms.enabled == true ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id = local.oms.workspace_id
    }
  }
  default_node_pool {
    auto_scaling_enabled         = local.node_default_pool.auto_scaling_enabled
    max_count                    = local.node_default_pool.max_count
    min_count                    = local.node_default_pool.min_count
    name                         = local.node_default_pool.name
    node_count                   = local.node_default_pool.node_count
    node_labels                  = local.node_default_pool.node_labels
    only_critical_addons_enabled = local.node_default_pool.only_critical_addons_enabled
    os_disk_size_gb              = local.node_default_pool.os_disk_size_gb
    os_disk_type                 = local.node_default_pool.os_disk_type
    os_sku                       = local.node_default_pool.os_sku
    tags                         = local.tags
    vm_size                      = local.node_default_pool.vm_size
    vnet_subnet_id               = local.subnet_id
    zones                        = local.zones != [] ? local.zones : null

    # if unset in the default block, it will set itself so we mirror that to avoid unessisary drift detection
    upgrade_settings {
      drain_timeout_in_minutes      = try(local.node_default_pool.upgrade_settings.drain_timeout_in_minutes, 0)
      max_surge                     = try(local.node_default_pool.upgrade_settings.max_surge, "10%")
      node_soak_duration_in_minutes = try(local.node_default_pool.upgrade_settings.node_soak_duration_in_minutes, 0)
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }
  network_profile {
    network_plugin = "azure"
  }
  tags = local.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  # due to auto-scaling we need to ignore the nodecount after launch
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
  count                 = local.node_user_pool.enabled ? 1 : 0
  auto_scaling_enabled  = local.node_user_pool.auto_scaling_enabled
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  max_count             = local.node_user_pool.max_count
  min_count             = local.node_user_pool.min_count
  mode                  = local.node_user_pool.mode
  name                  = local.node_user_pool.name
  node_count            = local.node_user_pool.node_count
  node_labels           = local.node_user_pool_merged.node_labels
  node_taints           = local.node_user_pool_merged.node_taints
  os_disk_size_gb       = local.node_user_pool.os_disk_size_gb
  os_disk_type          = local.node_user_pool.os_disk_type
  os_sku                = local.node_user_pool.os_sku
  os_type               = local.node_user_pool.os_type
  priority              = local.node_user_pool.priority
  eviction_policy       = local.node_user_pool.priority == "Spot" ? local.node_user_pool.eviction_policy : null
  spot_max_price        = local.node_user_pool.priority == "Spot" ? local.node_user_pool.spot_max_price : null
  tags                  = local.tags
  vm_size               = local.node_user_pool.vm_size
  vnet_subnet_id        = local.subnet_id # must be defined or terraform will redeploy despite documentation stating optional
  zones                 = local.zones != [] ? local.zones : null

  dynamic "upgrade_settings" {
    for_each = local.node_user_pool.upgrade_settings != null ? [local.node_user_pool.upgrade_settings] : []

    content {
      drain_timeout_in_minutes      = upgrade_settings.value.drain_timeout_in_minutes
      max_surge                     = upgrade_settings.value.max_surge
      node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
    }
  }

}
