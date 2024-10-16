resource "humanitec_resource_definition" "ingress" {
  id          = "${var.prefix}ingress"
  name        = "${var.prefix}ingress"
  type        = "ingress"
  driver_type = "humanitec/ingress"

  driver_inputs = {
    values_string = jsonencode({
      "annotations" : {
        "nginx.ingress.kubernetes.io/service-upstream" : "true"
      },
      "api_version" : "v1",
      "class" : "nginx"
    })
  }
}

resource "humanitec_resource_definition_criteria" "ingress" {
  resource_definition_id = humanitec_resource_definition.ingress.id
  env_id                 = var.environment
  env_type               = var.environment_type
  force_delete           = true
}