resource "azurerm_windows_virtual_machine_scale_set" "vm_windows_scalset" {
  name                = var.scalsetname
  resource_group_name = data.azurerm_resource_group.RG.name
  location            = data.azurerm_resource_group.RG.location
  sku                 = var.vmss_size
  instances           = var.instance_count
  admin_password      = var.admin_password
  admin_username      = var.admin_username
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }
    os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "uswinvmss01-nic01"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.internalsubnet.id
    }
  }
}


resource "azurerm_monitor_autoscale_setting" "policyscaling" {
  name                = var.autoscale_name
  resource_group_name = data.azurerm_resource_group.RG.name
  location            = data.azurerm_resource_group.RG.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.vm_windows_scalset.id

  profile {
    name = "AutoScale"

    capacity {
      default = 2
      minimum = var.autoscale_min
      maximum = var.autoscale_max
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vm_windows_scalset.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vm_windows_scalset.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}