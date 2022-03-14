######
# required provider versions 
######
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = ">= 2.90"
    #azuread = ">= 1.0.0"
  }
}