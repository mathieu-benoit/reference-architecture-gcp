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
run_cmd cd $\{SCRIPTS_DIRECTORY}
run_cmd cd $\{TF_MODULE_SOURCE_FOLDER_PATH}
if [ "$\{ACTION}" = "create" ]
then
    run_cmd tofu init -no-color
    run_cmd tofu apply -auto-approve -input=false -no-color -var-file terraform.credentials.tfvars.json
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
    run_cmd tofu destroy -auto-approve -input=false -no-color -var-file terraform.credentials.tfvars.json
else
  echo "unrecognized ACTION: \"$\{ACTION}"\" > "$\{ERROR_FILE}"
  cat "$\{ERROR_FILE}" 1>&2
  exit 1
fi