resource "azurerm_container_registry" "oidc" {
  name                = "oidcdemoacr"
  resource_group_name = azurerm_resource_group.oidc.name
  location            = azurerm_resource_group.oidc.location
  sku                 = "Basic"
  admin_enabled       = false
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.oidc.id
    ]
  }
}

resource "azurerm_role_definition" "acr_build" {
  name  = "AcrBuildRole"
  scope = data.azurerm_subscription.this.id
  permissions {
    actions = [
      # see `az provider operation show --namespace Microsoft.ContainerRegistry`
      "Microsoft.ContainerRegistry/registries/read",
      "Microsoft.ContainerRegistry/registries/pull/read",
      "Microsoft.ContainerRegistry/registries/push/write",
      "Microsoft.ContainerRegistry/registries/scheduleRun/action",
      "Microsoft.ContainerRegistry/registries/runs/*",
      "Microsoft.ContainerRegistry/registries/listBuildSourceUploadUrl/action",
    ]
    not_actions = []
  }
}

resource "azurerm_role_assignment" "oidc_acr" {
  scope                            = azurerm_container_registry.oidc.id
  role_definition_id               = azurerm_role_definition.acr_build.role_definition_resource_id
  principal_id                     = azurerm_user_assigned_identity.oidc.principal_id
  skip_service_principal_aad_check = true
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}




