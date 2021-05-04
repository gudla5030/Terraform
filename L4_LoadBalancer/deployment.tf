resource "azurerm_public_ip" "vmss-pip" {
  name                = "vmss-public-ip"
  resource_group_name = data.azurerm_resource_group.RG.name
  location            = data.azurerm_resource_group.RG.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "L4lb" {
  name                = var.loadbalancer_name
  location            = data.azurerm_resource_group.RG.location
  resource_group_name = data.azurerm_resource_group.RG.name

  frontend_ip_configuration {
    name                 = var.frontend_name
    public_ip_address_id = azurerm_public_ip.vmss-pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = data.azurerm_resource_group.RG.name
 loadbalancer_id     = azurerm_lb.L4lb.id
 name                = var.backendpool_name
}

resource "azurerm_lb_probe" "vmss" {
 resource_group_name = data.azurerm_resource_group.RG.name
 loadbalancer_id     = azurerm_lb.L4lb.id
 name                = var.health_prob
 port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = data.azurerm_resource_group.RG.name
   loadbalancer_id                = azurerm_lb.L4lb.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
   frontend_ip_configuration_name = var.frontend_name
   probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
 name                = var.vmss_name
 resource_group_name = data.azurerm_resource_group.RG.name
 location            = data.azurerm_resource_group.RG.location
 sku {
        name     = "Standard_B1s"
        tier     = "Standard"
        capacity = 3
    }
 upgrade_policy_mode = "Manual"



    storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
    }

    storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }

    storage_profile_data_disk {
    lun          = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 5
    }
    os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = var.admin_user
    admin_password       = var.admin_password
    custom_data          = file("web.conf")
    }

    os_profile_linux_config {
    disable_password_authentication = false
    }

     network_profile {
        name    = var.networkprofile
        primary = true

     ip_configuration {
     name                                   = "IPConfiguration"
     subnet_id                              = data.azurerm_subnet.internalsubnet.id
     load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
     primary = true
   }
 }
}