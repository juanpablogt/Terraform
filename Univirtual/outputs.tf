# ==================== EC2 INSTANCES OUTPUTS ====================
output "power_bi_server_id" {
  description = "Power BI Server Instance ID"
  value       = aws_instance.power_bi_server.id
}

output "power_bi_server_public_ip" {
  description = "Power BI Server Public IP"
  value       = aws_instance.power_bi_server.public_ip
}

output "email_server_id" {
  description = "Email Server Instance ID"
  value       = aws_instance.email_server.id
}

output "email_server_public_ip" {
  description = "Email Server Public IP"
  value       = aws_instance.email_server.public_ip
}

output "llama_container_id" {
  description = "Llama Container Instance ID"
  value       = aws_instance.llama_container.id
}

output "llama_container_public_ip" {
  description = "Llama Container Public IP"
  value       = aws_instance.llama_container.public_ip
}

output "web_moodle_id" {
  description = "Web Moodle Instance ID"
  value       = aws_instance.web_moodle.id
}

output "web_moodle_public_ip" {
  description = "Web Moodle Public IP"
  value       = aws_instance.web_moodle.public_ip
}

# ==================== RDS OUTPUTS ====================
output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = aws_db_instance.moodle_db.endpoint
}

output "rds_address" {
  description = "RDS Database Address"
  value       = aws_db_instance.moodle_db.address
}

output "rds_port" {
  description = "RDS Database Port"
  value       = aws_db_instance.moodle_db.port
}

output "rds_database_name" {
  description = "RDS Database Name"
  value       = aws_db_instance.moodle_db.db_name
}

output "rds_identifier" {
  description = "RDS Instance Identifier"
  value       = aws_db_instance.moodle_db.id
}

# ==================== S3 OUTPUTS ====================
output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.backups.bucket
}

output "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  value       = aws_s3_bucket.backups.arn
}

# ==================== VPC OUTPUTS ====================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.private[*].id
}

# ==================== SECURITY GROUPS OUTPUTS ====================
output "ec2_security_group_id" {
  description = "EC2 Security Group ID"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

# ==================== SUMMARY ====================
output "architecture_summary" {
  description = "Architecture Summary"
  value = {
    region               = var.aws_region
    project_name         = var.project_name
    ec2_instances_count  = 4
    ec2_instance_type    = var.instance_type
    rds_instance_class   = var.db_instance_class
    s3_bucket_name       = aws_s3_bucket.backups.bucket
    availability_zones   = data.aws_availability_zones.available.names
  }
}
