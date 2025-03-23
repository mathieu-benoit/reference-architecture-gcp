locals {
  vertexai_tf_module_source_folder_path = "gcp-vertex-ai"
}

resource "humanitec_resource_definition" "gcp_vertex_ai_default" {
  driver_type    = "humanitec/container"
  id             = "${var.prefix}vertex-ai-default"
  name           = "${var.prefix}vertex-ai-default"
  type           = "gcp-vertex-ai"
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
          TF_MODULE_SOURCE_FOLDER_PATH = local.vertexai_tf_module_source_folder_path
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
          file = "${local.vertexai_tf_module_source_folder_path}/terraform.credentials.tfvars.json"
        }
      }
      source = {
        ref = "refs/heads/main"
        url = "https://github.com/mathieu-benoit/terraform-modules-samples.git"
      }
      files = {
        "run.sh"                                                               = file("${path.module}/scripts/run-tofu.sh")
        "${local.vertexai_tf_module_source_folder_path}/terraform.tfvars.json" = "{\"app_id\": \"$${context.app.id}\", \"env_id\": \"$${context.env.id}\",\"res_id\": \"$${context.res.id}\", \"project_id\": \"$${resources['config.default#app'].outputs.gcp_project_id}\", \"location\": \"$${resources['config.default#app'].outputs.gcp_region}\"}"
        "${local.vertexai_tf_module_source_folder_path}/backend.tf"            = file("${path.module}/scripts/default-tf-backend.tf.include")
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

  provision = {
    "gcp-iam-policy-binding.vertex-ai-default" = {
      is_dependent = true
    }
  }
}

resource "humanitec_resource_definition_criteria" "gcp_vertex_ai_default" {
  resource_definition_id = humanitec_resource_definition.gcp_vertex_ai_default.id
  class                  = "default"
  force_delete           = true
}