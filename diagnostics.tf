# This enables diagnostic logging for aks
resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                      = local.oms.enabled == true ? 1 : 0
  name                       = "default policy"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  storage_account_id         = local.oms.storage_account_id
  log_analytics_workspace_id = local.oms.workspace_id

  dynamic "enabled_log" {
    for_each = local.oms.aks_logs
    content {
      category = enabled_log.key
      retention_policy {
        enabled = enabled_log.value
        days    = local.oms.retention_days
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = local.oms.aks_metrics
    retention_policy {
      enabled = local.oms.aks_metrics
      days    = local.oms.retention_days
    }
  }
}

# enable diagnostics for app gateway
resource "azurerm_monitor_diagnostic_setting" "agw" {
  count                      = (local.oms.enabled == true && local.app_gateway.enabled == true) ? 1 : 0
  name                       = "default policy"
  target_resource_id         = azurerm_application_gateway.main[0].id
  storage_account_id         = local.oms.storage_account_id
  log_analytics_workspace_id = local.oms.workspace_id

  dynamic "enabled_log" {
    for_each = local.oms.agw_logs
    content {
      category = enabled_log.key
      retention_policy {
        enabled = enabled_log.value
        days    = local.oms.retention_days
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = local.oms.agw_metrics
    retention_policy {
      enabled = local.oms.agw_metrics
      days    = local.oms.retention_days
    }
  }
}