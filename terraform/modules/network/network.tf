resource "azurerm_virtual_network" "main" {
  name                 = "${var.prefix}-vnet"
  address_space        = var.address_space
  location             = var.location
  resource_group_name  = var.resource_group
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.address_prefix]
}
