# This enables diagnostic logging for aks
resource "azurerm_monitor_diagnostic_setting" "main" {
  count                      = local.oms != {} ? 1 : 0
  name                       = "default policy"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  storage_account_id         = local.oms.storage_account_id
  log_analytics_workspace_id = local.oms.workspace_id
  log {
    category = "kube-apiserver"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-audit"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = false
    retention_policy {
      enabled = false
      days    = 0
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "guard"
    enabled  = false
    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# enable diagnostics for app gateway
resource "azurerm_monitor_diagnostic_setting" "agw" {
  count                      = local.oms != {} ? 1 : 0
  name                       = "default policy"
  target_resource_id         = azurerm_application_gateway.main.id
  storage_account_id         = local.oms.storage_account_id
  log_analytics_workspace_id = local.oms.workspace_id
  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}