resource "humanitec_resource_definition" "terraform_runner" {
  driver_type = "humanitec/template"
  id          = "terraform-runner"
  name        = "terraform-runner"
  type        = "config"

  driver_inputs = {
    secret_refs = jsonencode({
      agent_url = {
        value = "$${resources['agent.default#agent'].outputs.url}"
      }
      test_test = {
        ref   = "my-secret"
        store = "primary"
      }
    })
    values_string = jsonencode({
      templates = {
        outputs = {
          use_default_backend = true
          runner = {
            cluster_type = "gke"
            account      = "$${context.org.id}/${humanitec_resource_account.cluster_account.id}"
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
        }
        secrets = {
          agent_url = "{{ .driver.secrets.agent_url }}"
          test_test = "{{ .driver.secrets.test_test }}"
        }
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "terraform_runner" {
  resource_definition_id = humanitec_resource_definition.terraform_runner.id
  res_id                 = "tf-runner"
  force_delete           = true
}
