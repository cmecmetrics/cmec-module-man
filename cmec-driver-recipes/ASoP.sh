#!/bin/bash

source cmec-driver-recipes/bash_helper_functions.sh

module_name="ASoP"

# Clone source code from Github
cd $CMEC_MODULES_HOME
git_clone "github.com" "nick-klingaman/ASoP" $module_name

# Create required conda environments
# yaml file paths are relative to module directory
yaml_file_1="ASoP-Coherence/asop_coherence_env.yml"
yaml_file_2="ASoP-Spectral/ASoP1_Spectral/asop_spectral_env.yml"
conda_env_from_yaml $module_name $yaml_file_1 $yaml_file_2
