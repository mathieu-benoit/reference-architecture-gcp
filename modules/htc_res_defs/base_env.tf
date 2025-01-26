# This base-env is just to test the custom TF runner.
resource "humanitec_resource_definition" "base_env" {
  driver_type = "humanitec/container"
  id          = "${var.prefix}base-env"
  name        = "${var.prefix}base-env"
  type        = "base-env"

  driver_inputs = {
    values_string = jsonencode({
      job = {
        image = "ghcr.io/opentofu/opentofu:1.9.0"
        command = [
          "/bin/sh",
          "/home/runneruser/workspace/run.sh"
        ]
        shared_directory = "/home/runneruser/workspace"
        namespace        = "humanitec-runner"
        service_account  = "humanitec-runner"
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
      "source" = {
        ref = "refs/heads/main"
        url = "https://github.com/mathieu-benoit/terraform-modules-samples.git"
        # path = "echo"
      }
      files = {
        "run.sh"                = <<END_OF_TEXT
#!/bin/sh
run_cmd ()
{
    if ! "$@" 2> "$\{ERROR_FILE}"
    then
        echo
        echo "FAILED: $@"
        cat "$\{ERROR_FILE}" 1>&2
        exit 1
    fi
}
if ! [ -d "$\{SCRIPTS_DIRECTORY}" ]
then
    echo "SCRIPTS_DIRECTORY does not exist: \"$\{SCRIPTS_DIRECTORY}"\" > "$\{ERROR_FILE}"
    cat "$\{ERROR_FILE}" 1>&2
    exit 1
fi
run_cmd cd "$\{SCRIPTS_DIRECTORY}"
run_cmd ls -l
if [ "$\{ACTION}" = "create" ]
then
    run_cmd tofu init -no-color
    run_cmd tofu apply -auto-approve -input=false -no-color
    mkdir output_parse_container
    echo '{"in":' > output_parse_container/terraform.tfvars.json
    run_cmd tofu output -json >> output_parse_container/terraform.tfvars.json
    echo '}' >> output_parse_container/terraform.tfvars.json
    run_cmd cd output_parse_container
    echo 'variable "in" { type = map }
output "values" { value = {for k, v in var.in: k => v.value if !v.sensitive} }
output "secrets" { value = {for k, v in var.in: k => v.value if v.sensitive} }' > parse.tf
    echo
    echo "Converting outputs using tofu apply"
    run_cmd tofu apply -auto-approve -input=false -no-color > /dev/null
    run_cmd tofu output -json values > "$\{OUTPUTS_FILE}"
    run_cmd tofu output -json secrets > "$\{SECRET_OUTPUTS_FILE}"
    echo "Done."
elif [ "$\{ACTION}" = "destroy" ]
then
    run_cmd tofu init -no-color
    run_cmd tofu destroy -auto-approve -input=false -no-color
else
  echo "unrecognized ACTION: \"$\{ACTION}"\" > "$\{ERROR_FILE}"
  cat "$\{ERROR_FILE}" 1>&2
  exit 1
fi
END_OF_TEXT
        "terraform.tfvars.json" = "{\"input\": \"$${context.app.id}\"}\n"
        "backend.tf"            = <<END_OF_TEXT
terraform {
  backend "kubernetes" {
    secret_suffix    = "$${context.res.guresid}"
    in_cluster_config = true
    namespace = "humanitec-runner"
  }
}
END_OF_TEXT
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

resource "humanitec_resource_definition_criteria" "base_env" {
  resource_definition_id = humanitec_resource_definition.base_env.id
  force_delete           = true
}
