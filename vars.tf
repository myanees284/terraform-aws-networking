#Creating variables to substitute into the AWS resource creation. command -var vpc_cidr=<cidr block>
variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type    = string
}

# Declaring the region
variable "region" {
  default = "us-east-2"
  type    = string
}

# Declaring the region
variable "public_subnet_ids" {
  default = "dummy"
  type    = string
}