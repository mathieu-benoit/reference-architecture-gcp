locals {
  primary_secret_store = "primary"
  default_secret_store = "default"
}

resource "humanitec_secretstore" "primary" {
  id      = local.primary_secret_store
  primary = true
  gcpsm = {
    project_id = "not used is the orchestrator per se."
  }
}

resource "humanitec_secretstore" "default" {
  id = local.default_secret_store
  gcpsm = {
    project_id = "not used is the orchestrator per se."
  }
}

resource "humanitec_key" "operator" {
  key = var.operator_public_key
}