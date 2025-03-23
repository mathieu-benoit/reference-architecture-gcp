To run this `run-tofu.sh` file locally, do this:
```bash
sed -i 's/$\\{/${/g' run-tofu.sh

export ERROR_FILE=errors.txt
export SCRIPTS_DIRECTORY=.
export ACTION="create"
export OUTPUTS_FILE=outputs.txt
export SECRET_OUTPUTS_FILE=secret-outputs.txt
export TF_MODULE_SOURCE_FOLDER_PATH=.

./run-tofu.sh
```