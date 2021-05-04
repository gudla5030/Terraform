data "azurerm_resource_group" "RG" {
  name = "Terraform-Scalset"
}

data "azurerm_virtual_network" "virtualnetwork" {
  name                = "vNet001"
  resource_group_name = data.azurerm_resource_group.RG.name
}

data "azurerm_subnet" "internalsubnet" {
  name                 = "internal"
  virtual_network_name = data.azurerm_virtual_network.virtualnetwork.name
  resource_group_name  = data.azurerm_resource_group.RG.name
}