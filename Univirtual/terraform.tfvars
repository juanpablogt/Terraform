# AWS Configuration
aws_region   = "us-east-1"
project_name = "cloud-arch"

# VPC Configuration
vpc_cidr     = "10.0.0.0/16"
subnet_count = 3

# EC2 Configuration
instance_type = "t3.micro"

# RDS Configuration
db_name               = "moodle-db"
db_engine_version     = "16.1"
db_instance_class     = "db.t3.micro"
db_allocated_storage  = 20
db_database_name      = "moodle"
db_master_username    = "root"

# IMPORTANT: Change this password to something secure!
db_master_password = "MoodlePass123!"

# Backup Configuration
skip_final_snapshot     = true
backup_retention_period = 7
