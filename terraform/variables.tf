variable "env_prefix" {
  type        = string
  description = "Environment prefix like dev, prod"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "vpc_cidr_block" {
  type        = string
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
}
