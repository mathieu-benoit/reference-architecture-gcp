resource "humanitec_application" "backstage" {
  id   = "backstage"
  name = "backstage"
}

resource "humanitec_environment" "backstage_development" {
  app_id = humanitec_application.backstage.id
  id     = "development"
  name   = "Development"
  type   = "development"
}

# Configure required values for backstage

resource "humanitec_value" "backstage_github_org_id" {
  app_id      = humanitec_application.backstage.id
  key         = "GITHUB_ORG_ID"
  description = ""
  value       = var.github_org_id
  is_secret   = false
}

resource "humanitec_value" "backstage_github_app_id" {
  app_id      = humanitec_application.backstage.id
  key         = "GITHUB_APP_ID"
  description = ""
  value       = local.github_app_id
  is_secret   = false
}

resource "google_secret_manager_secret" "backstage_github_app_client_id" {
  secret_id = "github-app-client-id"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "backstage_github_app_client_id" {
  secret = google_secret_manager_secret.backstage_github_app_client_id.id

  secret_data = local.github_app_client_id
}
resource "humanitec_value" "backstage_github_app_client_id" {
  app_id      = humanitec_application.backstage.id
  key         = "GITHUB_APP_CLIENT_ID"
  description = ""
  is_secret   = true
  secret_ref  = {
    ref   = google_secret_manager_secret.backstage_github_app_client_id.secret_id
    store = var.humanitec_secret_store_id
  }
}

resource "google_secret_manager_secret" "backstage_github_app_client_secret" {
  secret_id = "github-app-client-secret"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "backstage_github_app_client_secret" {
  secret = google_secret_manager_secret.backstage_github_app_client_secret.id

  secret_data = local.github_app_client_secret
}
resource "humanitec_value" "backstage_github_app_client_secret" {
  app_id      = humanitec_application.backstage.id
  key         = "GITHUB_APP_CLIENT_SECRET"
  description = ""
  is_secret   = true
  secret_ref  = {
    ref   = google_secret_manager_secret.backstage_github_app_client_secret.secret_id
    store = var.humanitec_secret_store_id
  }
}

resource "google_secret_manager_secret" "backstage_github_app_private_key" {
  secret_id = "github-app-private-key"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "backstage_github_app_private_key" {
  secret = google_secret_manager_secret.backstage_github_app_private_key.id

  secret_data = indent(2, local.github_app_private_key)
}
resource "humanitec_value" "backstage_github_app_private_key" {
  app_id      = humanitec_application.backstage.id
  key         = "GITHUB_APP_PRIVATE_KEY"
  description = ""
  is_secret   = true
  secret_ref  = {
    ref   = google_secret_manager_secret.backstage_github_app_private_key.secret_id
    store = var.humanitec_secret_store_id
  }
}

resource "google_secret_manager_secret" "backstage_github_app_webhook_secret" {
  secret_id = "github-app-webhook-secret"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "backstage_github_app_webhook_secret" {
  secret = google_secret_manager_secret.backstage_github_app_webhook_secret.id

  secret_data = local.github_webhook_secret
}
resource "humanitec_value" "backstage_github_app_webhook_secret" {
  app_id      = humanitec_application.backstage.id
  key         = "GITHUB_APP_WEBHOOK_SECRET"
  description = ""
  is_secret   = true
  secret_ref  = {
    ref   = google_secret_manager_secret.backstage_github_app_webhook_secret.secret_id
    store = var.humanitec_secret_store_id
  }
}

resource "humanitec_value" "backstage_humanitec_org" {
  app_id      = humanitec_application.backstage.id
  key         = "HUMANITEC_ORG_ID"
  description = ""
  value       = var.humanitec_org_id
  is_secret   = false
}

resource "google_secret_manager_secret" "backstage_humanitec_token" {
  secret_id = "humanitec-token"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "backstage_humanitec_token" {
  secret = google_secret_manager_secret.backstage_humanitec_token.id

  secret_data = var.humanitec_ci_service_user_token
}
resource "humanitec_value" "backstage_humanitec_token" {
  app_id      = humanitec_application.backstage.id
  key         = "HUMANITEC_TOKEN"
  description = ""
  is_secret   = true
  secret_ref  = {
    ref   = google_secret_manager_secret.backstage_humanitec_token.secret_id
    store = var.humanitec_secret_store_id
  }
}

resource "humanitec_value" "backstage_cloud_provider" {
  app_id      = humanitec_application.backstage.id
  key         = "CLOUD_PROVIDER"
  description = ""
  value       = "gcp"
  is_secret   = false
}

resource "random_bytes" "backstage_service_to_service_auth_key" {
  length = 24
}

resource "google_secret_manager_secret" "app_config_backend_auth_keys" {
  secret_id = "backend-auth-keys"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "app_config_backend_auth_keys" {
  secret = google_secret_manager_secret.app_config_backend_auth_keys.id

  secret_data = jsonencode([{
    secret = random_bytes.backstage_service_to_service_auth_key.base64
  }])
}
resource "humanitec_value" "app_config_backend_auth_keys" {
  app_id      = humanitec_application.backstage.id
  key         = "APP_CONFIG_backend_auth_keys"
  description = "Backstage service-to-service-auth keys"
  is_secret = true
  secret_ref  = {
    ref   = google_secret_manager_secret.app_config_backend_auth_keys.secret_id
    store = var.humanitec_secret_store_id
  }
}

# Configure required resources for backstage

# in-cluster postgres

module "backstage_postgres" {
  source = "git::https://github.com/humanitec-architecture/resource-packs-in-cluster.git//humanitec-resource-defs/postgres/basic"

  prefix = "in-cluster"
}

resource "humanitec_resource_definition_criteria" "backstage_postgres" {
  resource_definition_id = module.backstage_postgres.id

  force_delete = true
}
