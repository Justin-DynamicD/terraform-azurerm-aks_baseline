######
# required provider versions
######
terraform {
  required_version = ">= 1.11.0"
  required_providers {
    azurerm = ">= 4.28.0"
    random  = ">= 3.7.0"
  }
}
