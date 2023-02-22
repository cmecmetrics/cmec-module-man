#!/bin/bash

source cmec-driver-recipes/bash_helper_functions.sh

module_name="XWMT"

# Clone source code from Github
cd $CMEC_MODULES_HOME
git_clone "github.com" "cmecmetrics/cmec_xwmt" $module_name

# Create required conda environments
# yaml file paths are relative to module directory
conda_env_from_yaml $module_name "xwmt_env.yaml"

# Define a reusable function for downloading sample data.
# This can then be wrapped in a prompt.
xwmt_install_sample_data () {
    source ${CONDA_SOURCE}
    conda activate ${CONDA_ENV_DIR}/_CMEC_xwmt_env
    mkdir -p ${CMEC_DATA_DIR}
    mkdir -p ${CMEC_DATA_DIR}/model_directory
    mkdir -p ${CMEC_DATA_DIR}/obs_directory
    #python ${CMEC_TMP_DIR}/$archive_name/doc/jupyter/Demo/download_sample_data.py ${CMEC_DATA_DIR}
    python ${CMEC_MODULE_DIR}/make_example_data.py ${CMEC_DATA_DIR}/model_directory ${CMEC_DATA_DIR}/obs_directory
    tar -xvf ${CMEC_DATA_DIR}/model_directory/xwmt_input_example.tar.gz -C  ${CMEC_DATA_DIR}/model_directory/
    tar -xvf ${CMEC_DATA_DIR}/obs_directory/xwmt/xwmt_obs_est_cmec.tar.gz -C  ${CMEC_DATA_DIR}/obs_directory/xwmt/
    rm ${CMEC_DATA_DIR}/model_directory/xwmt_input_example.tar.gz
    rm ${CMEC_DATA_DIR}/obs_directory/xwmt/xwmt_obs_est_cmec.tar.gz
    echo
    echo "Sample data downloaded to "${CMEC_DATA_DIR}/model_directory" and "${CMEC_DATA_DIR}/obs_directory
}
# Download sample data
if [ $USE_PROMPTS == "1" ]; then
    while true; do
        read -p "Download XWMT sample data (800 MB) to directory "${CMEC_DATA_DIR}"? [Y/n] "  yn
        case $yn in
            [Nn]* ) echo "Skipping sample data download"
                    break;;
            * ) xwmt_install_sample_data
                break;;
        esac
    done
else
    # Default is to download sample data
    xwmt_install_sample_data
fi
