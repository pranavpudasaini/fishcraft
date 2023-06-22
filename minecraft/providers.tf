terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=0.1"
    }
  }
  required_version = "~>1.4.5"
}

provider "azurerm" {
  features {}
}

