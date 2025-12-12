variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "devops-multicloud-project"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-east1-b"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
  default     = "devops-vpc"
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.2.0.0/24"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "devops-gke-cluster"
}

variable "gke_num_nodes" {
  description = "Number of GKE nodes"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "bucket_name" {
  description = "Cloud Storage bucket name"
  type        = string
  default     = "devops-multicloud-bucket"
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "devops-mysql-instance"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "devopsdb"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}
