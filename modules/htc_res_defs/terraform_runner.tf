resource "humanitec_resource_definition" "terraform-runner" {
  driver_type = "humanitec/echo"
  id          = "${var.prefix}terraform-runner"
  name        = "${var.prefix}terraform-runner"
  type        = "config"

  driver_inputs = {
    values_string = jsonencode({
      "name"         = var.k8s_cluster_name
      "loadbalancer" = var.k8s_loadbalancer
      "project_id"   = var.k8s_project_id
      "zone"         = var.k8s_region
    })

    secret_refs = jsonencode({
      credentials = {
        # FIXME - hard-coded value, should be passed via var.
        ref   = "terraform-runner-cluster-credentials"
        store = local.primary_secret_store
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "terraform-runner" {
  resource_definition_id = humanitec_resource_definition.terraform-runner.id
  env_id                 = var.environment
  env_type               = var.environment_type
  res_id                 = "terraform-runner"
  force_delete           = true
}