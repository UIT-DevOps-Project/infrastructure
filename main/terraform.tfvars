project = "uit-devops-nt548"
region  = "us-east-1"

azs             = ["us-east-1a", "us-east-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

# EKS
cluster_version            = "1.32"
app_node_instance_type     = "t3.small"
app_node_min               = 2
app_node_max               = 6
app_node_desired           = 2
monitor_node_instance_type = "t3.small"

# RDS Staging
rds_staging_instance_class = "db.t3.micro"
rds_staging_storage        = 20

# RDS Production
rds_production_instance_class = "db.t3.micro"
rds_production_storage        = 20

admin_iam_arn = "arn:aws:iam::597284493459:user/terraform-deployer"
domain        = ""  # thêm domain sau khi có
