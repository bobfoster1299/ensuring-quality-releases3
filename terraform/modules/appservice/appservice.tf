resource "azurerm_app_service_plan" "main" {
  name                = "${var.appservice_name}-plan"
  location            = var.location
  resource_group_name = var.resource_group

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "main" {
  name                = var.appservice_name
  location            = var.location
  resource_group_name = var.resource_group
  app_service_plan_id = azurerm_app_service_plan.main.id
  app_settings        = {
    "WEBSITE_RUN_FROM_PACKAGE" = 0
  }
}