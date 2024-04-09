locals {
  primary_secret_store = "primary"
}

resource "humanitec_secretstore" "default" {
  id = "default"
  gcpsm = {
    project_id = var.k8s_project_id
    auth = {
      secret_access_key = "${var.default_secret_store_access_credentials}"
    }
  }
}

resource "humanitec_secretstore" "primary" {
  id      = local.primary_secret_store
  primary = true
  gcpsm = {
    project_id = var.k8s_project_id
  }
}