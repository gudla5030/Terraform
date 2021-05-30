resource "azurerm_private_endpoint" "example" {
  name                = "example-endpoint"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  subnet_id           = azurerm_subnet.endpoint.id

  #subresource_names     = "blob"

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

}

data "azurerm_private_endpoint_connection" "endpoint-connection" {
  depends_on          = [azurerm_private_endpoint.example]
  name                = azurerm_private_endpoint.example.name
  resource_group_name = azurerm_resource_group.RG.name
}