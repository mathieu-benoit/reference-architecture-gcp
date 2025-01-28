resource "humanitec_resource_definition" "app_config" {
  driver_type    = "humanitec/echo"
  id             = "${var.prefix}app-config"
  name           = "${var.prefix}app-config"
  type           = "config"
  driver_account = humanitec_resource_account.cluster_account.id
  driver_inputs = {
    values_string = jsonencode({
      "gcp_project_id" = var.k8s_project_id
      "gcp_region"     = var.k8s_region
    })
  }
}

resource "humanitec_resource_definition_criteria" "app_config" {
  resource_definition_id = resource.humanitec_resource_definition.app_config.id
  res_id                 = "app"
  force_delete           = true
}