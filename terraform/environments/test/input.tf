# Azure subscription vars
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Resource Group/Location
variable "location" {}
variable "resource_group" {}

# Network
variable "address_prefix" {}
variable "address_space" {}

# AppService
variable "appservice_name" {}

# VM
variable "admin_username" {}

# prefix for resource names
variable "prefix" {}
