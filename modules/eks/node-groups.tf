# -------------------------------------------------------
# IAM Role — EKS Nodes (dùng chung cho cả 2 node groups)
# -------------------------------------------------------
resource "aws_iam_role" "node" {
  name = "${var.project}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# -------------------------------------------------------
# Security Group — Nodes
# -------------------------------------------------------
resource "aws_security_group" "node" {
  name        = "${var.project}-eks-node-sg"
  description = "EKS node security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow control plane to communicate with nodes"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-eks-node-sg"
  }
}

# -------------------------------------------------------
# Node Group — app-nodes (staging + production workloads)
# -------------------------------------------------------
resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "app-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.app_node_instance_type]

  scaling_config {
    min_size     = var.app_node_min
    max_size     = var.app_node_max
    desired_size = var.app_node_desired
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    node-group = "app-nodes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}

# -------------------------------------------------------
# Node Group — monitor-node (Prometheus, Grafana, OpenSearch)
# -------------------------------------------------------
resource "aws_eks_node_group" "monitor" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "monitor-node"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [var.private_subnet_ids[0]]
  instance_types  = [var.monitor_node_instance_type]

  scaling_config {
    min_size     = 1
    max_size     = 1
    desired_size = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    node-group = "monitor-node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}
