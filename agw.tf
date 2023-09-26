# Public Ip
resource "azurerm_public_ip" "main" {
  count               = (local.app_gateway.enabled && local.app_gateway.public_ip && local.app_gateway.public_ip_id == "") ? 1 : 0
  name                = local.names.agw
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.zones != [] ? local.zones : null
  tags                = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_application_gateway" "main" {
  lifecycle {
    # as this ends up managed by aks, we need to ignore changes here
    # we only care that it is created and permissions assigned
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      firewall_policy_id,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      ssl_certificate,
      tags,
      waf_configuration,
      url_path_map
    ]
  }

  count               = local.app_gateway.enabled ? 1 : 0
  name                = local.names.agw
  resource_group_name = local.resource_group_name
  location            = local.location
  zones               = local.zones != [] ? local.zones : null
  sku {
    name     = local.app_gateway.sku_name
    tier     = local.app_gateway.sku_tier
    capacity = local.app_gateway.sku_capacity
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = local.app_gateway.subnet_id
  }
  frontend_port {
    name = "defaulthttp"
    port = 80
  }
  dynamic "frontend_ip_configuration" {
    for_each = local.app_gateway.public_ip ? ["public_ip_configuration"] : []
    content {
      name                 = "appGatewayFrontendPublicIP"
      public_ip_address_id = local.app_gateway.public_ip_id == "" ? azurerm_public_ip.main[0].id : local.app_gateway.public_ip_id
    }
  }
  dynamic "frontend_ip_configuration" {
    for_each = local.app_gateway.private_ip ? ["private_ip_configuration"] : []
    content {
      name                          = "appGatewayFrontendPrivateIP"
      private_ip_address_allocation = local.private_ip_address_allocation
      private_ip_address            = local.app_gateway.private_ip_address
      subnet_id                     = coalesce(local.app_gateway.private_ip_subnet_id, local.app_gateway.subnet_id)
    }
  }
  backend_address_pool {
    name = "defaultaddresspool"
  }
  backend_http_settings {
    name                  = "defaulthttpsetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }
  dynamic "http_listener" {
    for_each = local.app_gateway.public_ip ? ["public_listener"] : []
    content {
      name                           = "publiclistener"
      frontend_ip_configuration_name = "appGatewayFrontendPublicIP"
      frontend_port_name             = "defaulthttp"
      protocol                       = "Http"
    }
  }
  dynamic "http_listener" {
    for_each = local.app_gateway.private_ip ? ["private_listener"] : []
    content {
      name                           = "privatelistener"
      frontend_ip_configuration_name = "appGatewayFrontendPrivateIP"
      frontend_port_name             = "defaulthttp"
      protocol                       = "Http"
    }
  }
  dynamic "request_routing_rule" {
    for_each = local.app_gateway.public_ip ? ["public_rr"] : []
    content {
      name                       = "public"
      rule_type                  = "Basic"
      http_listener_name         = "publiclistener"
      backend_address_pool_name  = "defaultaddresspool"
      backend_http_settings_name = "defaulthttpsetting"
      priority                   = local.public_priority != -1 ? local.public_priority : null
    }
  }
    dynamic "request_routing_rule" {
    for_each = local.app_gateway.private_ip ? ["private_rr"] : []
    content {
      name                       = "private"
      rule_type                  = "Basic"
      http_listener_name         = "privatelistener"
      backend_address_pool_name  = "defaultaddresspool"
      backend_http_settings_name = "defaulthttpsetting"
      priority                   = local.private_priority != -1 ? local.private_priority : null
    }
  }
  dynamic "waf_configuration" {
    for_each = local.is_v2 ? ["waf_configuration"] : []
    content {
      enabled                  = local.waf_configuration.enabled
      firewall_mode            = local.waf_configuration.firewall_mode
      rule_set_type            = local.waf_configuration.rule_set_type
      rule_set_version         = local.waf_configuration.rule_set_version
      file_upload_limit_mb     = local.waf_configuration.file_upload_limit_mb
      request_body_check       = local.waf_configuration.request_body_check
      max_request_body_size_kb = local.waf_configuration.max_request_body_size_kb
    }
  }
  tags = local.tags
}
