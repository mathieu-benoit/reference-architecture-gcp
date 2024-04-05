resource "humanitec_resource_definition" "k8s_service_account" {
  driver_type = "humanitec/template"
  id          = "${var.prefix}k8s-service-account"
  name        = "${var.prefix}k8s-service-account"
  type        = "k8s-service-account"

  driver_inputs = {
    values_string = jsonencode({
      templates = {
        init      = <<EOL
name: {{ index (regexSplit "\\." "$${context.res.id}" -1) 1 }}
EOL
        manifests = <<EOL
service-account.yaml:
  location: namespace
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: {{ .init.name }}
EOL
        outputs   = <<EOL
name: {{ .init.name }}
EOL
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_service_account" {
  resource_definition_id = humanitec_resource_definition.k8s_service_account.id
  env_id                 = var.environment
  env_type               = var.environment_type
  force_delete           = true
}
