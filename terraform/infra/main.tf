data "azurerm_client_config" "current" {}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.this.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.this.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

locals {
  common_tags = merge(var.tags, {
    project     = var.project_name
    environment = var.environment
  })

  api_service_account_name      = "${var.release_name}-three-tier-app-api-sa"
  postgres_service_account_name = "${var.release_name}-three-tier-app-postgres-sa"
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Standard"
  admin_enabled                 = false
  public_network_access_enabled = true
  tags                          = local.common_tags
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = var.user_assigned_identity_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.common_tags
}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
  rbac_authorization_enabled    = true
  tags                          = local.common_tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = local.common_tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "kv_admin_for_current_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_secrets_user_for_workload" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = var.db_user
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.kv_admin_for_current_user]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.kv_admin_for_current_user]
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "db-name"
  value        = var.db_name
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.kv_admin_for_current_user]
}

resource "azurerm_federated_identity_credential" "api" {
  name      = "fic-api"
  parent_id = azurerm_user_assigned_identity.workload.id
  issuer    = azurerm_kubernetes_cluster.this.oidc_issuer_url
  audience  = ["api://AzureADTokenExchange"]
  subject   = "system:serviceaccount:${var.namespace}:${local.api_service_account_name}"
}

resource "azurerm_federated_identity_credential" "postgres" {
  name      = "fic-postgres"
  parent_id = azurerm_user_assigned_identity.workload.id
  issuer    = azurerm_kubernetes_cluster.this.oidc_issuer_url
  audience  = ["api://AzureADTokenExchange"]
  subject   = "system:serviceaccount:${var.namespace}:${local.postgres_service_account_name}"
}

resource "kubernetes_namespace" "ingress_nginx" {
  count = var.enable_cluster_addons ? 1 : 0

  metadata {
    name = "ingress-nginx"
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}

resource "helm_release" "ingress_nginx" {
  count = var.enable_cluster_addons ? 1 : 0

  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = false
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.13.2"
  wait             = true
  timeout          = 600

  depends_on = [kubernetes_namespace.ingress_nginx]
}
