output "ansible_server_public_ip" {
  description = "IP público do servidor Ansible"
  value       = module.ansible_server.public_ip_address
}

output "semaphore_url" {
  description = "URL para acessar o Semaphore"
  value       = "http://${module.ansible_server.public_ip_address}:3000"
}

output "lab_servers_public_ips" {
  value = module.servidores_lab.vm_public_ips
}

