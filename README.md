# Terraform AWS network module
This independent module creates 1 VPC, subnets based on number of AZs, internet gateway with public subnet attachment along with NAT gateway with private subnet attachment
## Usage
~~~
module "my_network" {
  source   = "github.com/myanees284/terraform-aws-networking"
  vpc_cidr = "15.0.0.0/16"
  region   = "us-east-2"
}
~~~
