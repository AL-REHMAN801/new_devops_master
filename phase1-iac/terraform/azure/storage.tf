# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${var.storage_account_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Blob Container
resource "azurerm_storage_container" "main" {
  name                  = "devops-container"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
