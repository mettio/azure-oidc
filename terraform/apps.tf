resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_service_plan" "oidc" {
  name                     = "asp-demo-${random_string.this.id}"
  location                 = azurerm_resource_group.oidc.location
  resource_group_name      = azurerm_resource_group.oidc.name
  os_type                  = "Linux"
  sku_name                 = "B1"
  per_site_scaling_enabled = false
  worker_count             = 1
  zone_balancing_enabled   = false
  tags = {
    Source  = "Terraform"
    UseCase = "Demo"
  }
}

resource "azurerm_linux_web_app" "oidc" {
  name                = "oidc-demo-service-${random_string.this.id}"
  location            = azurerm_resource_group.oidc.location
  resource_group_name = azurerm_resource_group.oidc.name
  service_plan_id     = azurerm_service_plan.oidc.id
  https_only          = true

  lifecycle {
    ignore_changes = [
      site_config["docker_image_tag"],
      logs["http_logs"]
    ]
  }
  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.oidc.name}.azurecr.io/service"
      docker_image_tag = "latest"
    }

    always_on                         = true
    health_check_path                 = "/api/v1/health"
    health_check_eviction_time_in_min = 10

    cors {
      allowed_origins = [
        "*.azurestaticapps.net",
      ]
    }

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.oidc.client_id
  }

  app_settings = {
    WEBSITES_PORT                       = 3000
    DOCKER_ENABLE_CI                    = true
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.oidc.login_server}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.oidc.id,
    ]
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 100
      }
    }
  }

  tags = {
    UseCase = "Demo"
    Source  = "Terraform"
  }

  depends_on = [azurerm_container_registry.oidc]
}

locals {
  api_username = azurerm_linux_web_app.oidc.site_credential.0.name
  api_password = azurerm_linux_web_app.oidc.site_credential.0.password
  api_name     = lower(azurerm_linux_web_app.oidc.name)
}

resource "azurerm_container_registry_webhook" "oidc" {
  name                = "${replace(azurerm_linux_web_app.oidc.name, "-", "")}Webhook"
  location            = azurerm_resource_group.oidc.location
  resource_group_name = azurerm_resource_group.oidc.name
  registry_name       = azurerm_container_registry.oidc.name

  # Service Hook defined when: azurerm_linux_web_app.api.app_settings.DOCKER_ENABLE_CI = true
  service_uri = "https://${local.api_username}:${local.api_password}@${local.api_name}.scm.azurewebsites.net/api/registry/webhook"
  actions     = ["push"]
  status      = "enabled"
  scope       = "service:*"
  custom_headers = {
    "Content-Type" = "application/json"
  }
}

# The UAI should have the permission to deploy App Service
# resource "azurerm_role_assignment" "uai_apps" {
#   scope                = azurerm_linux_web_app.oidc.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_user_assigned_identity.oidc.principal_id
# }

# againt:

resource "azurerm_role_definition" "apps_build_deploy" {
  name  = "AppsBuildDeployRole"
  scope = data.azurerm_subscription.this.id
  permissions {
    actions = [
      "Microsoft.Web/sites/Read",
      "Microsoft.Web/sites/Write",
      "Microsoft.Web/sites/publish/Action",
      "Microsoft.Web/sites/config/list/action",
      "Microsoft.Web/sites/publishxml/action",
      "Microsoft.Web/sites/config/write",
      "Microsoft.Web/sites/restart/action"
    ]
    not_actions = []
  }
  assignable_scopes = [
    data.azurerm_subscription.this.id,
  ]
}

resource "azurerm_role_assignment" "apps_build_deploy" {
  scope              = azurerm_linux_web_app.oidc.id
  role_definition_id = azurerm_role_definition.apps_build_deploy.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.oidc.principal_id
}
