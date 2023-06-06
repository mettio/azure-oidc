terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.3"
    }
  }
  required_version = "~> 1.3"
}

provider "azurerm" {
  features {
  }
}

provider "azuread" {}
