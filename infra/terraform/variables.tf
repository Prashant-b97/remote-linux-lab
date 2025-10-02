variable "aws_region" {
  description = "AWS region to deploy the lab into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Optional specific AMI ID to use instead of the default Ubuntu 22.04 image"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Name for the AWS EC2 key pair"
  type        = string
  default     = "remote-linux-lab"
}

variable "public_key_path" {
  description = "Path to the public SSH key that should be uploaded to AWS"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks permitted to access the instance over SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.42.1.0/24"
}

variable "tags" {
  description = "Common tags applied to every AWS resource"
  type        = map(string)
  default = {
    project = "remote-linux-lab"
    owner   = "replace-me"
  }
}
