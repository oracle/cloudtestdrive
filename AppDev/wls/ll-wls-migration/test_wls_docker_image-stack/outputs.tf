# Output the private and public IPs of the instance

output "instance_private_ips" {
  value = [module.wls_docker_host.instance_private_ips]
}

output "instance_public_ips" {
  value = [module.wls_docker_host.instance_public_ips]
}
