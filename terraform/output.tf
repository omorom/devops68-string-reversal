output "app_public_url" {
  description = "URL สำหรับเข้าใช้งานแอพ"
  value       = "http://${aws_instance.app_server.public_ip}:3011"
}