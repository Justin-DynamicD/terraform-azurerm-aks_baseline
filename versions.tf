######
# required provider versions 
######
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = ">= 3.32.0"
    random = ">= 3.4.0"
  }
}
