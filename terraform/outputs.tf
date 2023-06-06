output "ARM_TENANT_ID" {
  value = data.azurerm_client_config.this.tenant_id
}

output "ARM_SUBSCRIPTION_ID" {
  value = data.azurerm_client_config.this.subscription_id
}

# Here, we don't need the Client-Id of an azure app registration but the Client-Id of the
# app registration that is created in the background with the UAI
output "ARM_CLIENT_ID" {
  value = azurerm_user_assigned_identity.oidc.client_id
}

output "ARM_ACR_NAME" {
  value = azurerm_container_registry.oidc.name
}

output "ARM_APPS_NAME" {
  value = azurerm_linux_web_app.oidc.name
}
