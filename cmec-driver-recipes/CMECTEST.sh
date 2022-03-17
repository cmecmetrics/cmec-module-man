#!/bin/bash

# This script walks through the installation steps for the 
# example CMEC module.

source cmec-driver-recipes/bash_helper_functions.sh

# Get example repository from Github and write to module directory.
repo_name="cmecmetrics/example_cmec_module"
git_clone "github.com" $repo_name $CMEC_MODULE_DIR

# Create conda environment using yaml from repository.
package_name="Example CMEC Module"
yaml_file="test_env.yaml"

conda_env_from_yaml "$package_name" $yaml_file

# Create sample data. Need packages in module environment.
source $CONDA_SOURCE
conda activate _CMEC_test_env
echo "Creating test dataset."
cd $CMEC_MODULE_DIR
mkdir test_data/
python make_test_data.py test_data
echo "Test dataset created in "$CMEC_MODULE_DIR"test_data/."
conda deactivate
