
resource "azurerm_user_assigned_identity" "oidc" {
  name                = "uai-oidc-demo"
  location            = azurerm_resource_group.oidc.location
  resource_group_name = azurerm_resource_group.oidc.name
}

resource "azurerm_federated_identity_credential" "oidc" {
  name                = "fed-oidc-demo"
  resource_group_name = azurerm_resource_group.oidc.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.oidc.id
  subject             = "repo:mettio/azure-oidc:ref:refs/heads/main"
}
