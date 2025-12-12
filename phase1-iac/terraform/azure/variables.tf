variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "devops-multicloud-rg"
}

variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = map(string)
  default = {
    aks     = "10.1.1.0/24"
    db      = "10.1.2.0/24"
    default = "10.1.3.0/24"
  }
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "devops-aks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "storage_account_name" {
  description = "Storage account name (must be globally unique, lowercase, no special chars)"
  type        = string
  default     = "devopsmulticloud"
}

variable "sql_server_name" {
  description = "SQL Server name (must be globally unique)"
  type        = string
  default     = "devops-sql-server"
}

variable "sql_database_name" {
  description = "SQL Database name"
  type        = string
  default     = "devopsdb"
}

variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  default     = "ChangeMe123!@#"
  sensitive   = true
}
