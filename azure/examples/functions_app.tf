resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

variable "function_app_name" {
  description = "App functions"
  type        = list
  default     = ["itv-backend-app","itv-prepare-data"]

}

variable "function_app_storage_account_name" {
  description = "storage accounts for functions"
  type        = list
  default     = ["itv-functionapp-0987997678","itv-functionapp-098897767656767"]

}

resource "azurerm_resource_group" "func" {
  name     = "__resourcegroupname__"
  location = "__location__"
}


resource "azurerm_storage_account" "storage-backend" {
  name                     = "itvstoragebackend${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.func.name
  location                 = azurerm_resource_group.func.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "storage-prepare-data" {
  name                     = "itvstoragedata${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.func.name
  location                 = azurerm_resource_group.func.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_app_service_plan" "app" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.func.location
  resource_group_name = azurerm_resource_group.func.name

  sku {
    tier = "Standard"
    size = "Y1"
  }
}


resource "azurerm_application_insights" "function-backend" {
  name                = "itv-insight-backend-${random_integer.ri.result}"
  location            = azurerm_resource_group.func.location
  resource_group_name = azurerm_resource_group.func.name
  application_type    = "web"

}


resource "azurerm_application_insights" "function-prepare-data" {
  name                = "itv-insight-prepare-data-${random_integer.ri.result}"
  location            = azurerm_resource_group.func.location
  resource_group_name = azurerm_resource_group.func.name
  application_type    = "web"

}

resource "azurerm_function_app" "function-backend" {
  name                       = "itv-function-backend-${random_integer.ri.result}"
  location                   = azurerm_resource_group.func.location
  resource_group_name        = azurerm_resource_group.func.name
  app_service_plan_id        = azurerm_app_service_plan.app.id
  storage_account_name       = azurerm_storage_account.storage-backend.name
  storage_account_access_key = azurerm_storage_account.storage-backend.primary_access_key
  version                    = "~3"
  os_type                    = "linux"
  app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.function-backend.instrumentation_key}"
      }
  
}


resource "azurerm_function_app" "function-prepare-data" {
  name                       = "itv-function-prepare-data-${random_integer.ri.result}"
  location                   = azurerm_resource_group.func.location
  resource_group_name        = azurerm_resource_group.func.name
  app_service_plan_id        = azurerm_app_service_plan.app.id
  storage_account_name       = azurerm_storage_account.storage-prepare-data.name
  storage_account_access_key = azurerm_storage_account.storage-prepare-data.primary_access_key
  version                    = "~3"
  os_type                    = "linux"
  app_settings = {
      "itvstorage" = "${azurerm_storage_account.storage-prepare-data.primary_connection_string}"
      "FUNCTIONS_WORKER_RUNTIME" = "python"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.function-prepare-data.instrumentation_key}"
	  }
  
}


output "storage_info" {
   value = {
   itvstorage = azurerm_storage_account.storage-prepare-data.primary_connection_string
   backend_function = azurerm_function_app.function-backend.name,
   prepare-data_function = azurerm_function_app.function-prepare-data.name
   }
}