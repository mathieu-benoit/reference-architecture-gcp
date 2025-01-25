resource "humanitec_resource_definition" "workload" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}workload"
  name        = "${var.prefix}workload"
  type        = "workload"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = file("${path.module}/manifests/workload/init.gtpl")
        manifests = file("${path.module}/manifests/workload/manifests.gtpl")
        outputs   = file("${path.module}/manifests/workload/outputs.gtpl")
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "workload" {
  resource_definition_id = humanitec_resource_definition.workload.id
  force_delete           = true
}
