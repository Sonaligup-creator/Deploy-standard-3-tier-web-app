variable "location" {
  description = "Azure region for bootstrap resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name for Terraform remote state"
  type        = string
  default     = "rg-three-tier-tfstate"
}

variable "storage_account_name_prefix" {
  description = "Prefix for global-unique storage account"
  type        = string
  default     = "threetiertfstate"
}

variable "container_name" {
  description = "Blob container name used by Terraform backend"
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Tags applied to bootstrap resources"
  type        = map(string)
  default = {
    project     = "three-tier-app"
    managed_by  = "terraform"
    environment = "shared"
  }
}
