# This base-env is just to test the custom TF runner.
resource "humanitec_resource_definition" "base_env" {
  driver_type = "humanitec/terraform-runner"
  id          = "${var.prefix}base-env"
  name        = "${var.prefix}base-env"
  type        = "base-env"

  driver_inputs = {
    values_string = jsonencode({
      append_logs_to_error = true

      script = <<EOL
terraform {
    # Bring your own backend, by setting use_default_backend=false on the terraform-runner.
    #backend "gcs" {
    #    # FIXME - hard coded for now, needs to be passed as module's var.
    #    bucket  = "htc-ref-arch-cluster-terraform-runner-state"
    #}
}
output "output" {
    value = "simple-test-for-tf-runner"
}
EOL
    })
  }
}

resource "humanitec_resource_definition_criteria" "base_env" {
  resource_definition_id = humanitec_resource_definition.base_env.id
  env_id                 = var.environment
  env_type               = var.environment_type
  force_delete           = true
}
