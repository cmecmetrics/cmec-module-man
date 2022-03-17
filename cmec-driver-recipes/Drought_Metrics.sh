#!/bin/bash

source cmec-driver-recipes/bash_helper_functions.sh

cd $CMEC_MODULE_DIR
module_name="Drought Metrics"

# Clone source code from Github
repo_name="cmecmetrics/Drought_Metrics"
cd $CMEC_MODULES_HOME
git_clone "github.com" $repo_name "Drought_Metrics"

# Create required conda environments
yaml_file="drought_metrics.yml"
conda_env_from_yaml "$module_name" $yaml_file
