provider azurerm {
  features{}
}

resource azurerm_resource_group "example" {
  name = "example"
  location = "westus2"
}
