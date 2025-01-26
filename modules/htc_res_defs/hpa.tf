resource "humanitec_resource_definition" "hpa" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}hpa"
  name        = "${var.prefix}hpa"
  type        = "horizontal-pod-autoscaler"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = file("${path.module}/manifests/horizontal-pod-autoscaler/init.gtpl")
        manifests = file("${path.module}/manifests/horizontal-pod-autoscaler/manifests.gtpl")
        outputs   = file("${path.module}/manifests/horizontal-pod-autoscaler/outputs.gtpl")
      }
    })
  }
}

#resource "humanitec_resource_definition_criteria" "hpa" {
#  resource_definition_id = resource.humanitec_resource_definition.hpa.id
#}