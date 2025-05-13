provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false # only good for demo, remove in prod
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "basic-aks-baseline"
  location = "westus2"
}

# oms resources to connect to
resource "azurerm_log_analytics_workspace" "main" {
  name                = "basic-aks-la"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
}

resource "random_string" "nameSuffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  name                            = "basicaks${random_string.nameSuffix.result}" # keeps the global name unique to avoid collisions
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "RAGRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_log_analytics_solution" "containerinsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.main.location
  resource_group_name   = azurerm_resource_group.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# network to run on
module "myvnet" {
  source = "Justin-DynamicD/virtual_network/azurerm"
  global_settings = {
    name                = "aks_vnet"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
  }
  network = {
    address_spaces = ["10.10.0.0/16"]
  }
  subnets = {
    agw       = "10.10.10.0/26"
    aks_nodes = "10.10.16.0/20"
  }
}

module "aks" {
  source = "Justin-DynamicD/aks_baseline/azurerm"
  depends_on = [
    azurerm_resource_group.main,
    azurerm_log_analytics_workspace.main,
    azurerm_storage_account.main,
    azurerm_log_analytics_solution.containerinsights
  ]
  location            = azurerm_resource_group.main.location
  name_prefix         = "basicaks"
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.myvnet.vnet_subnets["aks_nodes"].id
  app_gateway = {
    enabled   = true
    subnet_id = module.myvnet.vnet_subnets["agw"].id
  }
  node_default_pool = {
    min_count  = 1
    node_count = 1
  }
  node_user_pool = {
    min_count  = 1
    node_count = 1
  }
  oms = {
    enabled            = true
    storage_account_id = azurerm_storage_account.main.id
    workspace_id       = azurerm_log_analytics_workspace.main.id
  }
}
