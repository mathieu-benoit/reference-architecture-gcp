#!/bin/bash
set -o errexit

templates=$(ls modules/htc_res_defs/manifests/)
for template in $templates;
do
  cp scripts/test.yaml modules/htc_res_defs/manifests/$template/test-$template.yaml
  cd modules/htc_res_defs/manifests/$template
  sed -i "s/type: TYPE/type: ${template}/g" test-$template.yaml
  yq -i '.entity.driver_inputs.values.templates.init = load_str("init.gtpl")' test-$template.yaml
  yq -i '.entity.driver_inputs.values.templates.manifests = load_str("manifests.gtpl")' test-$template.yaml
  yq -i '.entity.driver_inputs.values.templates.outputs = load_str("outputs.gtpl")' test-$template.yaml
  humctl resources test-definition test-$template.yaml --generate > test-$template-inputs.yaml
  sed -i 's/context.res.id: ""/context.res.id: "modules.test.externals.test"/g' test-$template-inputs.yaml
  sed -i 's/""/"test"/g' test-$template-inputs.yaml
  humctl resources test-definition test-$template.yaml --inputs test-$template-inputs.yaml
  rm test-$template.yaml
  rm test-$template-inputs.yaml
  cd ../../../../
done