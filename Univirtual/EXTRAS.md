# Extras - Mejoras y Extensiones

## 🚀 Características adicionales que puedes agregar

### 1. Load Balancer (ALB)

Agrega a `main.tf`:

```hcl
# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Security Group para ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

# Registra las instancias en el target group
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.web_moodle.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Output
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}
```

---

### 2. Auto Scaling Group

```hcl
# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "Hello from $(hostname -f)" > /var/www/html/index.html
  EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}
```

---

### 3. CloudWatch Monitoring

```hcl
# CloudWatch Alarm para CPU de RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS CPU exceeds 80%"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.moodle_db.id
  }
}

# CloudWatch Alarm para conexiones RDS
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${var.project_name}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS connections exceed 80"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.moodle_db.id
  }
}

# Log Group para RDS
resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/instance/moodle-db/error"
  retention_in_days = 7
}
```

---

### 4. Backup Automático a S3

```hcl
# IAM Role para EC2
resource "aws_iam_role" "ec2_backup_role" {
  name = "${var.project_name}-ec2-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Policy para acceso a S3
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-ec2-s3-policy"
  role = aws_iam_role.ec2_backup_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.backups.arn}/*"
      }
    ]
  })
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_backup" {
  name = "${var.project_name}-ec2-backup-profile"
  role = aws_iam_role.ec2_backup_role.name
}

# Script de backup en cron (ejecutar en la instancia)
# ssh ubuntu@<IP>
# crontab -e
# 0 2 * * * /home/ubuntu/backup-to-s3.sh
```

---

### 5. ElastiCache (Redis)

```hcl
# Security Group para ElastiCache
resource "aws_security_group" "elasticache_sg" {
  name_prefix = "${var.project_name}-ec-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-ec-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.project_name}-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.elasticache_sg.id]

  tags = {
    Name = "${var.project_name}-cache"
  }
}

output "elasticache_endpoint" {
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}
```

---

### 6. RDS Read Replica

```hcl
# Read Replica en otra AZ
resource "aws_db_instance" "moodle_db_replica" {
  identifier          = "${var.db_name}-replica"
  replicate_source_db = aws_db_instance.moodle_db.identifier
  instance_class      = var.db_instance_class
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "moodle-db-replica"
  }
}

output "rds_replica_endpoint" {
  value = aws_db_instance.moodle_db_replica.endpoint
}
```

---

### 7. SNS Notifications

```hcl
# SNS Topic para alertas
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

# SNS Subscription (email)
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "tu-email@ejemplo.com"
}

# Conectar CloudWatch a SNS
resource "aws_cloudwatch_metric_alarm" "rds_cpu_with_sns" {
  alarm_name          = "${var.project_name}-rds-cpu-high-sns"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.moodle_db.id
  }
}
```

---

## 📋 Checklist para Producción

- [ ] Cambiar contraseña RDS a algo fuerte
- [ ] Restringir SSH a tu IP solo
- [ ] Habilitar MFA en AWS Console
- [ ] Configurar backups automáticos
- [ ] Configurar CloudWatch alarms
- [ ] Implementar Load Balancer
- [ ] Configurar Auto Scaling
- [ ] Habilitar VPC Flow Logs
- [ ] Configurar AWS Systems Manager
- [ ] Documentar acceso y permisos
- [ ] Revisar costos con AWS Cost Calculator
- [ ] Configurar disaster recovery
- [ ] Realizar penetration testing
- [ ] Implementar WAF (Web Application Firewall)

---

## 🔗 Referencias

- [Terraform AWS Provider - Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/language/syntax/style)
