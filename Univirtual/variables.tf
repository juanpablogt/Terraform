variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "cloud-arch"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "power_bi_instance_type" {
  description = "EC2 instance type for the Power BI Windows Server"
  type        = string
  default     = "t3.medium"
}

variable "db_name" {
  description = "RDS instance identifier"
  type        = string
  default     = "moodle-db"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.1"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_database_name" {
  description = "Database name"
  type        = string
  default     = "moodle"
}

variable "db_master_username" {
  description = "Master username for database"
  type        = string
  default     = "root"
  sensitive   = true
}

variable "db_master_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_master_password) >= 8
    error_message = "Password must be at least 8 characters long."
  }
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}
