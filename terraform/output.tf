output "vpc_id" {
  value = aws_vpc.this.id
}
output "public_subnets" {
  value = values(aws_subnet.public)[*].id
}
output "private_subnets" {
  value = local.private_subnet_ids
}
output "alb_dns" {
  value = aws_lb.alb.dns_name
}
output "ecs_cluster" {
  value = aws_ecs_cluster.this.id
}