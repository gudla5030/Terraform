resource "azurerm_resource_group" "RG" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "service" {
  name                 = "sub-service"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_service_network_policies = true
}
resource "azurerm_subnet" "endpoint" {
  name                                           = "endpoint"
  resource_group_name                            = azurerm_resource_group.RG.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.2.0/24"]
  service_endpoints                              = ["Microsoft.Sql", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}
resource "azurerm_subnet" "example" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

# resource "azurerm_data_lake_store" "example" {
#   name                = "consumptiondatalake"
#   resource_group_name = azurerm_resource_group.RG.name
#   location            = azurerm_resource_group.example.location
#   encryption_state    = "Enabled"
#   encryption_type     = "ServiceManaged"
# }

resource "azurerm_storage_account" "example" {
  name                     = "storageaccount99887766"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }
  tags = {
    environment = "staging"
  }
}