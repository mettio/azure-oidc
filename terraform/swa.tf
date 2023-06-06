resource "azurerm_static_site" "this" {
  name                = "oidc-static-web-app"
  resource_group_name = azurerm_resource_group.oidc.name
  location            = azurerm_resource_group.oidc.location
  sku_tier            = "Standard"
  sku_size            = "Standard"
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.oidc.id
    ]
  }
  tags = {
    UseCase = "Demo",
    Source  = "Terraform"
  }
}

resource "azurerm_role_assignment" "oidc_swa" {
  scope                            = azurerm_static_site.this.id
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.oidc.principal_id
  skip_service_principal_aad_check = true
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}
