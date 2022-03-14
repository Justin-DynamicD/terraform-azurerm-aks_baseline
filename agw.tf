# Public Ip
resource "azurerm_public_ip" "main" {
  name                = "${local.global_settings.name_prefix}-${local.global_settings.environment}-agw"
  resource_group_name = local.global_settings.resource_group_name
  location            = local.global_settings.location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "Zone-Redundant"
  tags                = var.tags
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
      url_path_map
    ]
  }

  name                = "${local.global_settings.name_prefix}-${local.global_settings.environment}-agw"
  resource_group_name = local.global_settings.resource_group_name
  location            = local.global_settings.location
  zones               = local.network.zones != [] ? local.network.zones : null
  sku {
    name     = local.app_gateway.sku_name
    tier     = local.app_gateway.sku_tier
    capacity = local.app_gateway.sku_capacity
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = local.network.agw_subnet_id
  }
  frontend_port {
    name = "defaulthttp"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.main.id
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
  http_listener {
    name                           = "defaultlistener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "defaulthttp"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "default"
    rule_type                  = "Basic"
    http_listener_name         = "defaultlistener"
    backend_address_pool_name  = "defaultaddresspool"
    backend_http_settings_name = "defaulthttpsetting"
  }
  tags = local.tags
}