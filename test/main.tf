provider azurerm {
  features{}
}

resource azurerm_resource_group "test" {
  name = "test-virtual-network"
  location = "westus2"
}

module "myvnet" {
  source = "Justin-DynamicD/virtual_network/azurerm"
  global_settings  = {
    name                = "aks_vnet"
    location            = azurerm_resource_group.test.location
    resource_group_name = azurerm_resource_group.test.name
  }
  network = {
    address_spaces     = ["10.10.0.0/16"]
  }
  subnets = {
    agw          = "10.10.10.0/26"
    aks_ingress  = "10.10.10.64/26"
    aks_nodes    = "10.10.20.0/20"
    private_link = "10.10.10.128/26"
  }
  subnet_enforce_private_link_service_network_policies = {
    private_link = true
  }
  subnet_service_endpoints = {
    private_link = ["Microsoft.KeyVault","Microsoft.ContainerRegistry"]
  }
  tags = {
    Level   = "2"
    Terraform = true
  }
}