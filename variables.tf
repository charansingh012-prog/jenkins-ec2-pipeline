variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-05d2d839d4f73aafb"  # Ubuntu - ap-south-1
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "EC2 Instance Name"
  type        = string
  default     = "jenkins-provisioned-ec2"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
  default     = ""
}
