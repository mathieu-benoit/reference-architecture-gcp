locals {
  app_hub_app_tf_module_source_folder_path = "gcp-app-hub-app"
}

resource "humanitec_resource_definition" "app_hub_app" {
  driver_type    = "humanitec/container"
  id             = "${var.prefix}apphub-app"
  name           = "${var.prefix}apphub-app"
  type           = "${var.humanitec_org_id}/gcp-apphub-app"
  driver_account = "$${resources['config.default#app'].account}"

  driver_inputs = {
    values_string = jsonencode({
      job = {
        image = "ghcr.io/opentofu/opentofu:${local.opentofu_version}"
        command = [
          "/bin/sh",
          "/home/runneruser/workspace/run.sh"
        ]
        shared_directory = "/home/runneruser/workspace"
        namespace        = "humanitec-runner"
        service_account  = "humanitec-runner"
        "variables" = {
          TF_MODULE_SOURCE_FOLDER_PATH = local.app_hub_app_tf_module_source_folder_path
        }
      }
      cluster = {
        account = "$${context.org.id}/${humanitec_resource_account.cluster_account.id}"
        cluster = {
          name         = var.k8s_cluster_name
          project_id   = var.k8s_project_id
          zone         = var.k8s_region
          cluster_type = "gke"
        }
      }
      credentials_config = {
        script_variables = {
          variables = {
            access_token = "access_token"
          }
          file = "${local.app_hub_app_tf_module_source_folder_path}/terraform.credentials.tfvars.json"
        }
      }
      source = {
        ref = "refs/heads/main"
        url = "https://github.com/mathieu-benoit/terraform-modules-samples.git"
      }
      files = {
        "run.sh"                                                                  = file("${path.module}/scripts/run-tofu.sh")
        "${local.app_hub_app_tf_module_source_folder_path}/terraform.tfvars.json" = "{\"app_id\": \"$${context.app.id}\", \"env_id\": \"$${context.env.id}\", \"env_type\": \"$${context.env.type}\", \"project_id\": \"$${resources['config.default#gke'].outputs.gke_project_id}\", \"region\": \"$${resources['config.default#gke'].outputs.gke_region}\"}"
        "${local.app_hub_app_tf_module_source_folder_path}/backend.tf"            = file("${path.module}/scripts/default-tf-backend.tf.include")
      }
    })
    secret_refs = jsonencode({
      cluster = {
        agent_url = {
          value = "$${resources['agent.default#runner'].outputs.url}"
        }
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "app_hub_app" {
  resource_definition_id = humanitec_resource_definition.app_hub_app.id
  force_delete           = true
}
