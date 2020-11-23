resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-publicip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}