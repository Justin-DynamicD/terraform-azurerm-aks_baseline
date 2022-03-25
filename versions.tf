######
# required provider versions 
######
terraform {
  required_version = ">= 1.0.0"
  experiments = [module_variable_optional_attrs]
  required_providers {
    azurerm = ">= 3.0.1"
    #azuread = ">= 1.0.0"
  }
}