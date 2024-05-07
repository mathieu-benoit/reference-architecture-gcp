resource "humanitec_resource_account" "cluster_account" {
  id   = "${var.prefix}cluster"
  name = "${var.prefix}cluster"
  type = "gcp-identity"

  credentials = jsonencode({
    gcp_service_account = var.cluster_access_gsa_email
    gcp_audience        = "//iam.googleapis.com/${var.cluster_access_wi_pool_provider_name}"
  })
}

resource "humanitec_resource_definition" "k8s_cluster" {
  driver_type = "humanitec/k8s-cluster-gke"
  id          = "${var.prefix}cluster"
  name        = "${var.prefix}cluster"
  type        = "k8s-cluster"

  driver_account = humanitec_resource_account.cluster_account.id
  driver_inputs = {
    values_string = jsonencode({
      "name"         = var.k8s_cluster_name
      "loadbalancer" = var.k8s_loadbalancer
      "project_id"   = var.k8s_project_id
      "zone"         = var.k8s_region
    }),
    secrets_string = jsonencode({
      "agent_url" = "$${resources['agent.default#agent'].outputs.url}"
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_cluster" {
  resource_definition_id = humanitec_resource_definition.k8s_cluster.id
  env_id                 = var.environment
  env_type               = var.environment_type
  force_delete           = true
}