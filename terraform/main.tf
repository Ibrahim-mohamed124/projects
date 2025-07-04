resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  for_each          = var.public
  tags = {
    Name = "web"
  }
}
resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  for_each          = var.private
  tags = {
    Name = "app"
  }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  count  = 2
  tags = {
    Name = "private"
  }
}
resource "aws_route_table_association" "public_subnets" {
  subnet_id      = aws_subnet.web["${var.AZ[count.index]}"].id
  route_table_id = aws_route_table.public_route_table.id
  count          = 2
}
resource "aws_route_table_association" "private_subnets" {
  subnet_id      = aws_subnet.app["${var.AZ[count.index]}"].id
  route_table_id = aws_route_table.private_route_table[count.index].id
  count          = 2
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0" # All traffic to the internet
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_eip" "lb" {
  count = 2
}
resource "aws_nat_gateway" "private_subnets_nat" {
  allocation_id = aws_eip.lb[count.index].id
  subnet_id     = aws_subnet.app["${var.AZ[count.index]}"].id
  count         = 2
  tags = {
    Name = "gw NAT"
  }
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_subnets_nat[count.index].id
  count                  = 2
}


resource "aws_security_group" "webSG" {
  name   = "webSG"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
    }
  }
  tags = {
    Name = "webapp-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_ebs_volume" "ebs" {
  availability_zone = var.AZ[count.index]
  size              = 10
  count             = 2
  encrypted         = true
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"] # Canonical
}

resource "aws_instance" "web" {
  ami                         = "ami-0e40cbc388241f8ce"
  key_name                    = "test"
  instance_type               = "t3.micro"
  count                       = 2
  availability_zone           = var.AZ[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.webSG.id]
  subnet_id                   = aws_subnet.web["${var.AZ[count.index]}"].id
  user_data                   = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd.service
  sudo systemctl enable httpd.service
  echo "${var.AZ[count.index]}" > /var/www/html/index.html
  EOF

}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.ebs[count.index].id
  instance_id = aws_instance.web[count.index].id
  count       = 2
}

resource "aws_lb_target_group" "webTG" {
  name     = "webTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}


resource "aws_lb_target_group_attachment" "TG_attach" {
  target_group_arn = aws_lb_target_group.webTG.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
  count            = 2
}

resource "aws_lb" "ALB" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.AlbSG.id]
  subnets            = [for subnet in aws_subnet.web : subnet.id]
  

}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webTG.arn
  }

}

resource "aws_security_group" "AlbSG" {
  name   = "AlbSG"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.ports_ALB
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
    }
  }
  tags = {
    Name = "ALB-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_for_ALB" {
  security_group_id = aws_security_group.AlbSG.id
  referenced_security_group_id = aws_security_group.webSG.id
  to_port           = 80
  ip_protocol          = "tcp"
  from_port         = 80
}


resource "aws_launch_template" "web_template" {
  name_prefix   = "web"
  image_id      = "ami-0e40cbc388241f8ce"
  instance_type = "t3.micro"
  user_data              = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd.service
  sudo systemctl enable httpd.service
  EOF
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }
}

resource "aws_autoscaling_group" "ASG" {
  availability_zones = var.AZ
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "ASG_att" {
  autoscaling_group_name = aws_autoscaling_group.ASG.id
  lb_target_group_arn    = aws_lb_target_group.webTG.arn
}

