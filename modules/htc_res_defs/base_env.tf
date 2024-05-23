# This base-env is just to test the custom TF runner.
resource "humanitec_resource_definition" "base_env" {
  driver_type = "humanitec/terraform"
  id          = "${var.prefix}base-env"
  name        = "${var.prefix}base-env"
  type        = "base-env"

  driver_inputs = {
    values_string = jsonencode({
      append_logs_to_error = true
      runner_mode          = "custom-kubernetes"

      runner = {
        cluster_type = "gke"
        account      = "${var.humanitec_org_id}/${humanitec_resource_account.cluster_account.id}"
        cluster = {
          name       = var.k8s_cluster_name
          project_id = var.k8s_project_id
          zone       = var.k8s_region
        }
        # FIXME - hard coded for now, needs to be passed as module's var.
        service_account = "humanitec-terraform-runner"
        # FIXME - hard coded for now, needs to be passed as module's var.
        namespace = "humanitec-terraform-runner"
      }

      script = <<EOL
terraform {
    backend "gcs" {
        # FIXME - hard coded for now, needs to be passed as module's var.
        bucket  = "htc-ref-arch-cluster-terraform-runner-state"
    }
    #backend "kubernetes" {
    #  secret_suffix    = "state"
    #  in_cluster_config = true
    #  # FIXME - hard coded for now, needs to be passed as module's var.
    #  namespace = "humanitec-terraform-runner"
    #}
}
output "output" {
    value = "simple-test-for-tf-runner"
}
EOL
    })

    secret_refs = jsonencode({
      runner = {
        agent_url = {
          value = "$${resources['agent.default#agent'].outputs.url}"
        }
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "base_env" {
  resource_definition_id = humanitec_resource_definition.base_env.id
  env_id                 = var.environment
  env_type               = var.environment_type
  force_delete           = true
}
