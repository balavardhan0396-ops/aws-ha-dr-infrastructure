output "instance_id" {
  value = aws_instance.application_vm.id
}

output "public_ip" {
  value = aws_instance.application_vm.public_ip
}

output "ssh_command" {
  value = "ssh -i your-key.pem ec2-user@${aws_instance.application_vm.public_ip}"
}
