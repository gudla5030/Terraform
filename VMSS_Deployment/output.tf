output "Resoucegroupid" {
  value = data.azurerm_resource_group.RG.id
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.virtualnetwork.id
}

output "subnet_id" {
  value = data.azurerm_subnet.internalsubnet.id
}