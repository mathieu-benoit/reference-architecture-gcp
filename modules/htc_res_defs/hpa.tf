resource "humanitec_resource_definition" "hpa" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}hpa"
  name        = "${var.prefix}hpa"
  type        = "horizontal-pod-autoscaler"

  driver_inputs = {
    values_string = jsonencode(yamldecode(file("${path.module}/manifests/horizontal-pod-autoscaler/definition-values.yaml")))
  }
}

resource "humanitec_resource_definition_criteria" "hpa" {
  resource_definition_id = resource.humanitec_resource_definition.hpa.id
}

/*resource "humanitec_resource_definition" "hpa" {
  driver_type = "humanitec/hpa"
  id          = "hpa"
  name        = "hpa"
  type        = "horizontal-pod-autoscaler"
  driver_inputs = {
    values_string = jsonencode({
    })
  }
}*/