provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "__terraformstoragerg__"
    storage_account_name = "__terraformstorageaccount__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "__storagekey__"
  }
}

module "resource_group" {
  source         = "../../modules/resource_group"
  resource_group = var.resource_group
  location       = var.location
}

module "network" {
  source         = "../../modules/network"
  address_space  = var.address_space
  location       = var.location
  resource_group = module.resource_group.resource_group_name
  address_prefix = var.address_prefix
  prefix         = var.prefix
}

module "nsg" {
  source         = "../../modules/nsg"
  location       = var.location
  resource_group = module.resource_group.resource_group_name
  subnet_id      = module.network.subnet_id_main
  address_prefix = var.address_prefix
  prefix         = var.prefix
}

module "appservice" {
  source          = "../../modules/appservice"
  location        = var.location
  resource_group  = module.resource_group.resource_group_name
  prefix          = var.prefix
  appservice_name = var.appservice_name
}

module "publicip" {
  source          = "../../modules/publicip"
  location        = var.location
  resource_group  = module.resource_group.resource_group_name
  prefix          = var.prefix
}

module "vm" {
  source               = "../../modules/vm"
  location             = var.location
  resource_group       = module.resource_group.resource_group_name
  subnet_id            = module.network.subnet_id_main
  public_ip_address_id = module.publicip.public_ip_address_id 
  admin_username       = var.admin_username
  prefix               = var.prefix
}