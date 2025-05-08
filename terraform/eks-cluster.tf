module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "Fullstack-cluster"
  cluster_version = "1.28"

  # Allow public access to EKS API server
  cluster_endpoint_public_access = true

  # ✅ Use public subnets instead of private ones
  vpc_id     = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.public_subnets

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t2.medium"]

      # Optional: ensure nodes get public IPs if subnets don't auto-assign them
      # associate_public_ip_address = true
    }
  }
}
