variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "ResourceGroup"{}
variable "location" {}
variable "adress_range"{}
variable "lbinternal"{}
variable "nsg"{}
variable "loadbalancer_name" {}
variable "frontend_name"{}
variable "backendpool_name"{}
variable "health_prob"{}
variable "vmss_name"{}
variable "networkprofile"{}
variable "username"{}
variable "password"{}

variable "application_port" {
   description = "The port that you want to expose to the external load balancer"
   default     = 80
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
   default     = "azadmin"
}

variable "admin_password" {
   description = "Default password for admin account"
   default     = "Password@123"
}