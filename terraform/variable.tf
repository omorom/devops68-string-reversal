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