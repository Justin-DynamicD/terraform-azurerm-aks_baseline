######
# required provider versions 
######
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    azurerm = ">= 3.74.0"
    random  = ">= 3.4.0"
  }
}
