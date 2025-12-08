resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "simple-timeservice-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "simple-timeservice-igw" }
}

# Public subnets (2 AZs)
resource "aws_subnet" "public" {
  for_each = var.public_subnets.cidr 
  vpc_id            = aws_vpc.this.id 
  cidr_block        = each.value.cidr_block
  map_public_ip_on_launch = true
  availability_zone = eachvalue.availability_zone
  tags = { Name = each.key }
}

# Private subnets (2 AZs)
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  map_public_ip_on_launch = false
  tags = { Name = "private-${each.value}" }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateways (one per public subnet) + Elastic IP
# NOTE: This creates one NAT GW per public subnet.
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain = "vpc"
  tags = { Name = "nat-eip-${each.value.cidr_block}" }
}

resource "aws_nat_gateway" "natgw" {
  for_each = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = { Name = "nat-${each.value.cidr_block}" }
  depends_on = [aws_internet_gateway.igw]
}

# Private route tables, one per private subnet; route via a NAT in the same AZ (best-effort)
# For simplicity, map private subnet i -> NAT GW i by index.
locals {
  public_subnet_ids  = values(aws_subnet.public)[*].id
  natgw_ids          = values(aws_nat_gateway.natgw)[*].id
  private_subnet_ids = values(aws_subnet.private)[*].id
}

resource "aws_route_table" "private" {
  for_each = { for idx, id in local.private_subnet_ids : idx => id }
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = null
    nat_gateway_id = local.natgw_ids[each.key % length(local.natgw_ids)]
  }
  tags = { Name = "private-rt-${each.key}" }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_route_table.private
  subnet_id      = local.private_subnet_ids[each.key]
  route_table_id = each.value.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
