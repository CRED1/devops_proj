variable "aws_region" {}
variable "aws_profile" {}
#variable "access_key" {}
#variable "secret_access_key" {}

variable "localip" {}

variable "key_name" {}
variable "private_key_path" {}

# Pull data from aws
data "aws_availability_zones" "available" {}

#variable "vpc_cidr" {}

#variable "my_root_password" {}
