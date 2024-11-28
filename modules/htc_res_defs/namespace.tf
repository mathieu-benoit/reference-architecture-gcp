resource "humanitec_resource_definition" "k8s_namespace" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}namespace"
  name        = "${var.prefix}namespace"
  type        = "k8s-namespace"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = file("${path.module}/manifests/k8s-namespace/init.gtpl")
        manifests = file("${path.module}/manifests/k8s-namespace/manifests.gtpl")
        outputs   = file("${path.module}/manifests/k8s-namespace/outputs.gtpl")
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_namespace" {
  resource_definition_id = humanitec_resource_definition.k8s_namespace.id
  force_delete           = true
}