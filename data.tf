
######
# Data lookups
######

# import current Azure Data
# data "azurerm_subscription" "primary" {}
# data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "source" {
  name = local.resource_group_name
}

data "azurerm_container_registry" "list" {
  for_each            = local.acr_list
  name                = each.key
  resource_group_name = each.value
}