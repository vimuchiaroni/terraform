resource "random_integer" "dbri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "db" {
  name     = "__resourcegroupname__"
  location = "__location__"
}


resource "azurerm_cosmosdb_account" "db" {
  name                = "itv-weatherdb-sqlprov-${random_integer.dbri.result}"
  location            = azurerm_resource_group.db.location
  resource_group_name = azurerm_resource_group.db.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.db.location
    failover_priority = 0
  }
}

output "database_information" {
   value = azurerm_cosmosdb_account.db.connection_strings
}