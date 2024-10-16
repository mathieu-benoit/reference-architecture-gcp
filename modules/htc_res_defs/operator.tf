locals {
  primary_secret_store = "primary"
}

resource "humanitec_secretstore" "primary" {
  id      = local.primary_secret_store
  primary = true
  gcpsm = {
    project_id = var.k8s_project_id
  }
}

resource "humanitec_key" "operator" {
  key = var.operator_public_key
}