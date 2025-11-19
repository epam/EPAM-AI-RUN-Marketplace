variable "region" {
  description = "The AWS region to deploy the cluster into"
  type        = string
  default     = "eu-central-1"
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform"
  type        = string
  default     = "arn:aws:iam::012345678901:role/EKSDeployerRole"
}

variable "platform_domain_name" {
  description = "The name of existing DNS zone for platform"
  type        = string
  default     = "example.com"
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources"
  type        = string
  default     = "codemie"
}

variable "platform_cidr" {
  description = "CIRD of your future or existing VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_azs" {
  description = "Available zones of your future or existing subnets"
  type        = list(any)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "private_cidrs" {
  description = "CIRD of your future or existing VPC"
  type        = list(any)
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
}

variable "public_cidrs" {
  description = "CIRD of your future or existing VPC"
  type        = list(any)
  default     = ["10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
}

variable "security_group_ids" {
  description = "A list of security groups to apply to the Network Load Balancer and the Application Load Balancer"
  type        = list(any)
  default     = []
}

variable "ssl_policy" {
  description = "Predefined SSL security policy for ALB https listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.33"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = ""
}

variable "add_userdata" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script"
  type        = string
  default     = ""
}

variable "ebs_encrypt" {
  description = "Specifies whether the EBS volume should be encrypted."
  type        = bool
  default     = false

}

# Variables for spot pool
variable "spot_instance_types" {
  description = "AWS instance type to build nodes for spot pool"
  type        = list(any)
  default     = [{ instance_type = "m6a.2xlarge" }]
}

variable "spot_max_nodes_count" {
  description = "The maximum size of the spot autoscaling group"
  type        = number
  default     = 0
}

variable "spot_desired_nodes_count" {
  description = "The number of spot Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 0
}

variable "spot_min_nodes_count" {
  description = "The minimum size of the spot autoscaling group"
  type        = number
  default     = 0
}

variable "enable_spot_nodes_scheduler" {
  description = "Use this variable in case you would like to create schedule for scaling out your cluster in defined time."
  type        = bool
  default     = false
}

# Variables for on-demand pool
variable "demand_instance_types" {
  description = "AWS instance type to build nodes for on-demand pool"
  type        = list(any)
  default     = [{ instance_type = "m6a.2xlarge" }]
}

variable "demand_max_nodes_count" {
  description = "The maximum size of the on-demand autoscaling group"
  type        = number
  default     = 4
}

variable "demand_desired_nodes_count" {
  description = "The number of on-demand Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 2
}

variable "demand_min_nodes_count" {
  description = "The minimum size of the on-demand autoscaling group"
  type        = number
  default     = 2
}

variable "enable_demand_nodes_scheduler" {
  description = "Use this variable in case you would like to create schedule for scaling out your cluster in defined time."
  type        = bool
  default     = false
}

# OIDC Identity provider
variable "cluster_identity_providers" {
  description = "Configuration for OIDC identity provider"
  type        = any
  default     = {}
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_admin_role_arn" {
  description = "ARN of the IAM role that will have admin access to the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default = {
    "SysName"     = "AI/Run"
    "Environment" = "Development"
    "Project"     = "AI/Run"
  }
}

variable "enable_codemie_s3_file_storage" {
  description = "Control S3 bucket creation for users' data storage in CodeMie"
  type        = bool
  default     = true
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

