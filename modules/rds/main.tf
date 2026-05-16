terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# -------------------------------------------------------
# Random Password
# -------------------------------------------------------
resource "random_password" "db" {
  length  = 24
  special = false
}

# -------------------------------------------------------
# Security Group — chỉ cho EKS nodes kết nối
# -------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-${var.env}-sg"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-${var.env}-sg"
  }
}

# -------------------------------------------------------
# Subnet Group
# -------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-rds-${var.env}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project}-rds-${var.env}-subnet-group"
  }
}

# -------------------------------------------------------
# Parameter Group
# -------------------------------------------------------
resource "aws_db_parameter_group" "main" {
  name   = "${var.project}-rds-${var.env}-pg15"
  family = "postgres15"

  tags = {
    Name = "${var.project}-rds-${var.env}-pg15"
  }
}

# -------------------------------------------------------
# RDS Instance
# -------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier = "${var.project}-postgres-${var.env}"

  engine         = "postgres"
  engine_version = "15"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = "postgres"
  password = random_password.db.result

  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  multi_az               = var.multi_az
  publicly_accessible    = false
  deletion_protection       = false
  skip_final_snapshot       = true
  final_snapshot_identifier = null

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = {
    Name = "${var.project}-postgres-${var.env}"
    Env  = var.env
  }
}
