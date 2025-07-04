output "lb" {
  value = aws_eip.lb[*].public_ip
}

output "ip_1" {
  value = aws_instance.web[0].public_ip
}
output "ip_2" {
  value = aws_instance.web[1].public_ip
}

output "ALB_dns_name" {
 value = aws_lb.ALB.dns_name
}





