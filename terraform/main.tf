provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "app_sg" {
  name = "${var.instance_name}-sg"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0ed0867532b47cc2c"
  instance_type = var.instance_type
  key_name      = var.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
#!/bin/bash
set -e
exec > /home/ubuntu/setup.log 2>&1

apt update -y
apt install -y curl git

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

cd /home/ubuntu
git clone https://github.com/omorom/devops68-string-reversal.git

# แก้ permission (สำคัญมาก)
chown -R ubuntu:ubuntu /home/ubuntu/devops68-string-reversal

cd devops68-string-reversal

# install ด้วย ubuntu user
sudo -u ubuntu npm install

# run app
sudo -u ubuntu nohup node index.js > app.log 2>&1 &
EOF

  tags = {
    Name = var.instance_name
  }
}