provider azurerm {
  features{}
}

resource azurerm_resource_group "main" {
  name = "test-aks-baseline"
  location = "westus2"
}

module "myvnet" {
  source = "Justin-DynamicD/virtual_network/azurerm"
  global_settings  = {
    name                = "aks_vnet"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
  }
  network = {
    address_spaces     = ["10.10.0.0/16"]
  }
  subnets = {
    agw          = "10.10.10.0/26"
    aks_nodes    = "10.10.16.0/20"
  }
}

module "aks" {
  source = "../"
  depends_on = [
    azurerm_resource_group.test
  ]
  global_settings = {
    location            = azurerm_resource_group.main.location
    name_prefix         = "testaks"
    resource_group_name = azurerm_resource_group.main.name
  }
  aks = {
    os_disk_size_gb = 70
    subnet_id       = module.myvnet.vnet_subnets["aks_nodes"].id
    vm_size         = "Standard_D2ds_v5"
  }
  app_gateway = {
    enabled   = true
    subnet_id = module.myvnet.vnet_subnets["agw"].id
  }
}
