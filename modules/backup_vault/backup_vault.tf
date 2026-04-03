# naming convention
resource "azurecaf_name" "bckp" {

  name          = var.settings.backup_vault_name
  resource_type = "azurerm_data_protection_backup_vault"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                       = azurecaf_name.bckp.result
  location                   = var.location
  resource_group_name        = var.resource_group_name
  datastore_type             = var.settings.datastore_type
  redundancy                 = var.settings.redundancy
  tags                       = local.tags
  retention_duration_in_days = try(var.settings.retention_duration_in_days, "14")
  immutability               = try(var.settings.immutability, "Disabled") # Disabled, Locked, and Unlocked
  soft_delete                = try(var.settings.soft_delete, "On")        # On, Off, and AlwaysOn

  dynamic "identity" {
    for_each = can(var.settings.identity) ? [var.settings.identity] : []

    content {
      type         = try(identity.value.type, "SystemAssigned")
      identity_ids = concat(local.managed_identities, try(identity.value.identity_ids, []))
    }
  }

}

#
# Managed identities from remote state
#

locals {
  managed_local_identities = flatten([
    for managed_identity_key in try(var.settings.identity.managed_identity_keys, []) : [
      var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
    ]
  ])

  managed_remote_identities = flatten([
    for lz_key, value in try(var.settings.identity.remote, []) : [
      for managed_identity_key in value.managed_identity_keys : [
        var.remote_objects.managed_identities[lz_key][managed_identity_key].id
      ]
    ]
  ])

  managed_identities = concat(local.managed_local_identities, local.managed_remote_identities)
}