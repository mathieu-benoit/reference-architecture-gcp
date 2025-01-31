resource "humanitec_resource_definition" "k8s_service_account" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}k8s-service-account"
  name        = "${var.prefix}k8s-service-account"
  type        = "k8s-service-account"

  driver_inputs = {
    values_string = jsonencode(yamldecode(file("${path.module}/manifests/k8s-service-account/definition-values.yaml")))
  }
}

resource "humanitec_resource_definition_criteria" "k8s_service_account" {
  resource_definition_id = humanitec_resource_definition.k8s_service_account.id
  force_delete           = true
}
