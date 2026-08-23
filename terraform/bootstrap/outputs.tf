output "resource_group_name" {
  value       = azurerm_resource_group.tfstate.name
  description = "Resource group that stores Terraform state"
}

output "storage_account_name" {
  value       = azurerm_storage_account.tfstate.name
  description = "Storage account for Terraform backend"
}

output "container_name" {
  value       = azurerm_storage_container.tfstate.name
  description = "Blob container for Terraform backend"
}

output "backend_config" {
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
    key                  = "infra-dev.tfstate"
  }
  description = "Use these values in terraform init -backend-config"
}
