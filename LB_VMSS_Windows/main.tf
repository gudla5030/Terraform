resource "azurerm_resource_group" "RG" {
  name     = var.ResourceGroup
  location = var.location
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "https"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "RDPrule"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = var.adress_range
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.lbinternal
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["10.0.10.0/24"]
}
resource "azurerm_public_ip" "vmss-pip" {
  name                = "vmss-public-ip"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "L4lb" {
  name                = var.loadbalancer_name
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  frontend_ip_configuration {
    name                 = var.frontend_name
    public_ip_address_id = azurerm_public_ip.vmss-pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = azurerm_resource_group.RG.name
 loadbalancer_id     = azurerm_lb.L4lb.id
 name                = var.backendpool_name
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.RG.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.L4lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "vmss" {
 resource_group_name = azurerm_resource_group.RG.name
 loadbalancer_id     = azurerm_lb.L4lb.id
 name                = var.health_prob
 port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = azurerm_resource_group.RG.name
   loadbalancer_id                = azurerm_lb.L4lb.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
   frontend_ip_configuration_name = var.frontend_name
   probe_id                       = azurerm_lb_probe.vmss.id
}