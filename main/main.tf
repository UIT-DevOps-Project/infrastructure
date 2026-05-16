terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
    }
  }
}

# -------------------------------------------------------
# VPC
# -------------------------------------------------------
module "vpc" {
  source = "../modules/vpc"

  project         = var.project
  region          = var.region
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# -------------------------------------------------------
# ENI Cleanup — chạy sau khi EKS destroyed, trước khi VPC destroyed
#
# Lý do cần: EKS VPC CNI tạo ENIs không được Terraform quản lý.
# Khi destroy, các ENIs này còn sót lại khiến subnet không xóa được.
#
# Cơ chế dependency:
#   module.eks depends_on terraform_data.cleanup_vpc_enis
#   → Destroy order: EKS → cleanup (xóa ENIs) → VPC
# -------------------------------------------------------
resource "terraform_data" "cleanup_vpc_enis" {
  input = {
    vpc_id = module.vpc.vpc_id
    region = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Waiting for EKS to fully release resources..."
      sleep 30

      # Xóa ENIs còn sót (do VPC CNI tạo)
      ENIS=$(aws ec2 describe-network-interfaces \
        --filters "Name=vpc-id,Values=${self.input.vpc_id}" \
        --query "NetworkInterfaces[?Status=='available'].NetworkInterfaceId" \
        --output text --region ${self.input.region})
      for eni in $ENIS; do
        [ -n "$eni" ] && echo "Deleting ENI: $eni" && \
        aws ec2 delete-network-interface \
          --network-interface-id $eni \
          --region ${self.input.region} || true
      done

      # Xóa Security Groups do EKS tự tạo ngoài Terraform
      SGS=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=${self.input.vpc_id}" \
        --query "SecurityGroups[?GroupName!='default'].GroupId" \
        --output text --region ${self.input.region})
      for sg in $SGS; do
        [ -n "$sg" ] && echo "Deleting SG: $sg" && \
        aws ec2 delete-security-group \
          --group-id $sg \
          --region ${self.input.region} || true
      done

      echo "VPC resource cleanup done."
    EOT
  }
}

# -------------------------------------------------------
# EKS — 1 cluster cho cả staging + production namespaces
# depends_on cleanup: đảm bảo destroy order là EKS → cleanup → VPC
# -------------------------------------------------------
module "eks" {
  source = "../modules/eks"

  project                    = var.project
  cluster_version            = var.cluster_version
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  public_subnet_ids          = module.vpc.public_subnet_ids
  app_node_instance_type     = var.app_node_instance_type
  app_node_min               = var.app_node_min
  app_node_max               = var.app_node_max
  app_node_desired           = var.app_node_desired
  monitor_node_instance_type = var.monitor_node_instance_type
  admin_iam_arn              = var.admin_iam_arn

  depends_on = [terraform_data.cleanup_vpc_enis]
}

# -------------------------------------------------------
# Route53 + ACM — chỉ tạo khi có domain
# -------------------------------------------------------
module "acm" {
  count  = var.domain != "" ? 1 : 0
  source = "../modules/acm"
  domain = var.domain
}

# -------------------------------------------------------
# RDS — staging
# -------------------------------------------------------
module "rds_staging" {
  source = "../modules/rds"

  project               = var.project
  env                   = "staging"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  eks_node_sg_id        = module.eks.node_security_group_id
  eks_cluster_sg_id     = module.eks.cluster_security_group_id
  instance_class        = var.rds_staging_instance_class
  allocated_storage     = var.rds_staging_storage
  multi_az              = false
  backup_retention_days = 0
}

# -------------------------------------------------------
# RDS — production
# -------------------------------------------------------
module "rds_production" {
  source = "../modules/rds"

  project               = var.project
  env                   = "production"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  eks_node_sg_id        = module.eks.node_security_group_id
  eks_cluster_sg_id     = module.eks.cluster_security_group_id
  instance_class        = var.rds_production_instance_class
  allocated_storage     = var.rds_production_storage
  multi_az              = false
  backup_retention_days = 0
}
