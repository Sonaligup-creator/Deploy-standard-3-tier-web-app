variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project short name"
  type        = string
  default     = "three-tier"
}

variable "resource_group_name" {
  description = "Resource group for app infrastructure"
  type        = string
  default     = "rg-three-tier-dev"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-three-tier-dev"
}

variable "acr_name" {
  description = "Globally unique ACR name"
  type        = string
}

variable "key_vault_name" {
  description = "Globally unique Key Vault name"
  type        = string
}

variable "user_assigned_identity_name" {
  description = "User assigned identity name for workload identity"
  type        = string
  default     = "uami-three-tier-app"
}

variable "kubernetes_version" {
  description = "AKS kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_count" {
  description = "Default node count"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "AKS node vm size"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "namespace" {
  description = "Application namespace"
  type        = string
  default     = "three-tier"
}

variable "release_name" {
  description = "Helm release name used to compute service account names"
  type        = string
  default     = "three-tier"
}

variable "enable_cluster_addons" {
  description = "When true, deploy ingress-nginx and app namespace via Terraform after AKS is ready"
  type        = bool
  default     = false
}

variable "db_user" {
  description = "Database username stored in Key Vault"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password stored in Key Vault"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name stored in Key Vault"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
