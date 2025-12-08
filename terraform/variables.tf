variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    "public-a" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-south-1a"
    }
    "public-b" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-south-1b"
    }
  }
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "container_image" {
  type    = string
  default = "vijayrajkumar/simple-timeseries:latest" # replace with your image (e.g., youruser/simple-timeservice:latest)
}

variable "container_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  type    = number
  default = 2
}
