provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# resource group to place everything in
resource "azurerm_resource_group" "test" {
  name     = "test-aks-baseline"
  location = "westus2"
}

# oms resources to connect to
resource "azurerm_log_analytics_workspace" "main" {
  name                = "test-la"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "random_string" "nameSuffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  name                            = "testla${random_string.nameSuffix.result}" # keeps the global name unique to avoid collisions
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "RAGRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_log_analytics_solution" "containerinsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.main.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

module "myvnet" {
  source = "Justin-DynamicD/virtual_network/azurerm"
  global_settings = {
    name                = "aks_vnet"
    location            = azurerm_resource_group.test.location
    resource_group_name = azurerm_resource_group.test.name
  }
  network = {
    address_spaces = ["10.10.0.0/16"]
  }
  subnets = {
    agw          = "10.10.10.0/26"
    aks_ingress  = "10.10.10.64/26"
    aks_nodes    = "10.10.16.0/20"
    private_link = "10.10.10.128/26"
  }
  private_link_service_network_policies_enabled = {
    private_link = true
  }
  subnet_service_endpoints = {
    private_link = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
  }
  tags = {
    Project   = "AKS Baseline"
    CAF_Level = "2"
    Terraform = true
  }
}

module "aks" {
  source = "../"
  depends_on = [
    azurerm_resource_group.test,
    azurerm_log_analytics_workspace.main,
    azurerm_storage_account.main,
    azurerm_log_analytics_solution.containerinsights
  ]
  location            = azurerm_resource_group.test.location
  name_prefix         = "testaks"
  resource_group_name = azurerm_resource_group.test.name
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
    enabled = true
    # aks_logs = {
    #   guard = true
    # }
    storage_account_id = azurerm_storage_account.main.id
    workspace_id       = azurerm_log_analytics_workspace.main.id
  }
  tags = {
    Project   = "AKS Baseline"
    CAF_Level = "3"
    Terraform = true
  }
  zones = ["1", "2", "3"]
}
