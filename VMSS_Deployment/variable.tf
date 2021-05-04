variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "scalsetname" {}
variable "vmss_size" {}
variable "instance_count" {
    type    = number
    default = 2
}
variable "admin_password" {}
variable "admin_username" {}
variable "autoscale_name" {}
variable "autoscale_min" {
    type    = number
}
variable "autoscale_max" {
    type    = number
}


