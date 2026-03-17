# String Reversal API

Reverse any string.

## Endpoint

### GET `/reverse`

**Parameters:**
- `text` (required): Text to reverse

**Example Request:**
```
http://localhost:3011/reverse?text=hello
```

**Example Response:**
```json
{
  "input": "hello",
  "reversed": "olleh"
}
```

## Step by Step ที่อาจารย์สามารถทำตามขั้นตอนนี้ได้

ก่อนเริ่ม: ติดตั้ง Terraform CLI และ AWS CLI ให้เรียบร้อย

หลังจากนั้น ทำการสร้าง Security credentials เพื่อใช้ในการ deploy ด้วย Terraform: โดยมีขั้นตอนดังนี้:
เข้า AWS กดตรงหน้า account (มุมขวาบน) เลือก My Security Credentials หลังจากนั้นเลือก Access Keys และกด Create New Access Key
ให้ดาวน์โหลดไฟล์ .csv เก็บไว้ในเครื่อง และนำข้อมูล Access Key และ Secret Key ไปใช้ในการตั้งค่า AWS CLI ต่อไป

การตั้งค่าการเชื่อมต่อ AWS CLI:
เปิด terminal และรันคำสั่ง: aws configure
กรอก:
Access Key
Secret Key
Region (เช่น ap-southeast-1) ในส่วนนี้สามารถเลือก region ที่ต้องการได้ตามความสะดวก
Output format: json

การ Deploy ด้วย Terraform
สร้างโฟลเดอร์ชื่อ terraform และสร้างไฟล์:
main.tf, variables.tf, outputs.tf

ไปที่ AWS Console และสร้าง Key Pair ไว้ใน region ที่เราต้องการจะ deploy (โดยในส่วนนี้เราจะสร้างไว้ใน region: ap-southeast-1) และดาวน์โหลดไฟล์ .pem เก็บไว้ในเครื่อง

หลังจากนั้น แก้ไขไฟล์ variables.tf เพื่อกำหนดค่า:
region ซึ่งต้องตรงกับ region ที่สร้าง ในส่วนนี้อาจารย์สามารถเลือก region ที่ต้องการได้ตามความสะดวกแต่ต้องตรงกับที่สร้าง key pair ไว้
key pair name ซึ่งต้องตรงกับที่สร้างไว้ใน AWS Console
instance_type ซึ่งในที่นี้เราใช้ t3.micro ซึ่งอยู่ใน free tier
allowed ports ซึ่งในที่นี้เราจะเปิด port 22 สำหรับ SSH และ port 3011 สำหรับแอพของเรา

สร้างไฟล์ main.tf เพื่อกำหนด:
AWS provider ในส่วนนี้เราจะใช้เป็นของ AWS 
EC2 instance โดยเราสามารถเปลี่ยนในส่วนของ instance_type ได้ตามความต้องการ แต่ต้องตรงกับที่กำหนดไว้ใน variables.tf

สร้างไฟล์ outputs.tf เพื่อแสดง Public URL หลังจาก deploy เสร็จ

code variable.tf  
```
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "key_name" {
  description = "ชื่อ Key Pair สำหรับ SSH"
  type        = string
  default     = "66315078_key_pair"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
  default     = "string-reversal-server"
}

variable "allowed_ports" {
  description = "Ports to allow inbound traffic"
  type        = list(number)
  default     = [22, 3011]
}
```

code main.tf
```
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
git clone https://github.com/<your-project-name>/devops68-string-reversal.git 
example 
#git clone https://github.com/omorom/devops68-string-reversal.git

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
```
code output.tf
```
output "app_public_url" {
  description = "URL สำหรับเข้าใช้งานแอพ"
  value       = "http://${aws_instance.app_server.public_ip}:3011"
}
```


หลังจากทำการ ตั้งค่าเสร็จแล้ว ให้กลับมาที่ terminal และไปที่โฟลเดอร์ terraform จากนั้น
รันคำสั่ง:
```
terraform init
```

จากนั้นรัน:
```
terraform plan 
```
เพื่อดูว่า Terraform จะทำอะไรบ้าง 
และถ้าหากทุกอย่างถูกต้อง ให้รันคำสั่ง:
```
terraform apply
```
และพิมพ์ yes

หลังจาก deploy เสร็จ จะได้ Public IP และสามารถเข้าใช้งานได้ที่:

ซึ่งในที่นี้ให้แทน <public-ip> ด้วย Public IP ที่ได้จากตอนที่ deploy เสร็จแล้ว และทดสอบด้วย port 3011 ตามที่โจทย์กำหนดไว้

```
http://<public-ip>:3011/reverse?text=hello
```

ถ้าแอพยังไม่ทำงาน ให้ SSH เข้าไป:
```
ssh -i /path/to/key.pem ubuntu@<public-ip> #ดูได้จากตอนที่ deply เสร็จแล้ว
```

จากนั้นรัน:

-cd /home/ubuntu/devops68-string-reversal

-npm install express

-node index.js

### ทำการทดสอบอีกครั้งโดยการ
เปิด browser:
```
http://<public-ip>:3011/reverse?text=hello
```

จะได้ผลลัพธ์:
```
{
  "input": "hello",
  "reversed": "olleh"
}
```
