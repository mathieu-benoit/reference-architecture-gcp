resource "humanitec_resource_definition" "ingress-tmp" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}ingress-tmp"
  name        = "${var.prefix}ingress-tmp"
  type        = "ingress"

  driver_inputs = {
    values_string = jsonencode({
      annotations = {
        "nginx.ingress.kubernetes.io/service-upstream" : "true"
      }
      class = "nginx"
      templates = {
        init      = file("${path.module}/manifests/ingress/init.gtpl")
        manifests = file("${path.module}/manifests/ingress/manifests.gtpl")
        outputs   = file("${path.module}/manifests/ingress/outputs.gtpl")
      }
    })
  }
}

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
      "class" : "nginx"
    })
  }
}

resource "humanitec_resource_definition_criteria" "ingress" {
  resource_definition_id = humanitec_resource_definition.ingress.id
  force_delete           = true
}