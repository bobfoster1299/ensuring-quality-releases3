resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
}