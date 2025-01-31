#!/bin/bash
set -o errexit

templates=$(ls modules/htc_res_defs/manifests/)
for template in $templates;
do
  if [ "${template}" == "horizontal-pod-autoscaler" ] || [ "${template}" == "ingress" ]; then
    echo "## ${template} skipped."
    continue
  fi
  echo "## ${template} tested."
  cp scripts/test.yaml modules/htc_res_defs/manifests/$template/test-$template.yaml
  cd modules/htc_res_defs/manifests/$template
  
  yq -i '.entity.type = env(template)' test-$template.yaml
  
  yq -i '.entity.driver_inputs.values = load("definition-values.yaml")' test-$template.yaml
  
  humctl resources test-definition test-$template.yaml --generate > test-$template-inputs.yaml
  
  # TODO: replace sed with yq in this file
  # TODO: test cases with fixed inputs file (for regression tests) - for now it's just linting
  sed -i 's/context.res.id: ""/context.res.id: "modules.test.externals.test"/g' test-$template-inputs.yaml
  sed -i 's/""/"test"/g' test-$template-inputs.yaml
  
  humctl resources test-definition test-$template.yaml --inputs test-$template-inputs.yaml
  
  rm test-$template.yaml
  rm test-$template-inputs.yaml
  cd ../../../../
done