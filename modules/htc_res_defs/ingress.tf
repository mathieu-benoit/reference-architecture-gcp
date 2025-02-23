resource "humanitec_resource_definition" "ingress" {
  driver_type = "humanitec/ingress"
  id          = "${var.prefix}ingress"
  name        = "${var.prefix}ingress"
  type        = "ingress"
  driver_inputs = {
    values_string = jsonencode({
      "annotations" = {
        "nginx.ingress.kubernetes.io/service-upstream" = "true"
      }
      "class"  = "nginx"
    })
  }
}

resource "humanitec_resource_definition_criteria" "ingress" {
  resource_definition_id = humanitec_resource_definition.ingress.id
  force_delete           = true
}