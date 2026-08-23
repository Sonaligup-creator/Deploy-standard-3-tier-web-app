output "resource_group_name" {
  description = "Infrastructure resource group"
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.this.login_server
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "workload_identity_client_id" {
  description = "Client ID for workload identity"
  value       = azurerm_user_assigned_identity.workload.client_id
}

output "workload_identity_tenant_id" {
  description = "Tenant ID for workload identity"
  value       = data.azurerm_client_config.current.tenant_id
}

output "oidc_issuer_url" {
  description = "AKS OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "helm_service_account_subjects" {
  description = "Subjects expected by federated identity credentials"
  value = {
    api      = "system:serviceaccount:${var.namespace}:${local.api_service_account_name}"
    postgres = "system:serviceaccount:${var.namespace}:${local.postgres_service_account_name}"
  }
}
