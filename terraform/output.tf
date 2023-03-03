
# Cluster AKS
output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.aks.kube_config_raw
}

# Resource Group
output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

# vm
output "azurerm_public_ip" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.public_ip.ip_address
}
# output "public_ip_dns_name" {
#  description = "fqdn to connect to the first vm provisioned."
#  value       = azurerm_public_ip.vm[*].fqdn
# }
output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.ani01.private_ip_address
}
output "admin_username" {
  description = "The Username associated with the Container Registry Admin account - if the admin account is enabled."
  value       = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account - if the admin account is enabled."
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
