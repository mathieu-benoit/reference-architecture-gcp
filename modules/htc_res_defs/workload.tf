resource "humanitec_resource_definition" "workload" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}workload"
  name        = "${var.prefix}workload"
  type        = "workload"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        outputs = file("${path.module}/manifests/workload/outputs.gtpl")
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "workload" {
  resource_definition_id = humanitec_resource_definition.workload.id
  force_delete           = true
}
