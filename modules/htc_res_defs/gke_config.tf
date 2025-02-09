resource "humanitec_resource_definition" "gke_config" {
  driver_type = "humanitec/echo"
  id          = "${var.prefix}cluster-config"
  name        = "${var.prefix}cluster-config"
  type        = "config"
  driver_inputs = {
    values_string = jsonencode({
      "gke_project_id"     = var.k8s_project_id
      "gke_project_number" = var.k8s_project_number
      "gke_region"         = var.k8s_region
      "gke_name"           = var.k8s_cluster_name
    })
  }
}

resource "humanitec_resource_definition_criteria" "gke_config" {
  resource_definition_id = resource.humanitec_resource_definition.gke_config.id
  res_id                 = "gke"
  force_delete           = true
}