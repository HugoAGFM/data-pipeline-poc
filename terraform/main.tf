terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatehugoagfm"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}


# Provider
provider "azurerm" {
  features {}
}

# Service Plans
resource "azurerm_service_plan" "data_pipeline_sp" {
  name                = "data-pipeline-sp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}


# Storage Accounts
resource "azurerm_storage_account" "data_pipeline_sa" {
  name                     = "datapipelinesa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Containers
resource "azurerm_storage_container" "data_piepline_staging" {
  name                  = "staging"
  storage_account_name  = azurerm_storage_account.data_pipeline_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "data_piepline_validated" {
  name                  = "validated"
  storage_account_name  = azurerm_storage_account.data_pipeline_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "data_piepline_processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.data_pipeline_sa.name
  container_access_type = "private"
}


# Function Apps
resource "azurerm_linux_function_app" "data_pipeline_linux_fa" {
  name                = "data-pipeline-linux-fa"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.data_pipeline_sa.name
  storage_account_access_key = azurerm_storage_account.data_pipeline_sa.primary_access_key

  service_plan_id = azurerm_service_plan.data_pipeline_sp.id

#   app_settings = {
#     "username" = "hugoagfm",
#     "password" = "123456"
#   }
  
  site_config {}
}

# Key Vault
