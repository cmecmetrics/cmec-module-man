#!/bin/bash

# This script walks through the steps for installing the
# PCMDI Metrics Package for use with CMEC driver.

# import some standard functions
source cmec-driver-recipes/bash_helper_functions.sh

# Get latest version number, which can be substituted into a template
# for the release tarball in the next steps.
pmp_version="$(get_latest_repository_tag "PCMDI/pcmdi_metrics" "v2.3.1")"
pmp_version_number=$( echo ${pmp_version} | cut -d 'v' -f 2 ) # strip leading 'v'

# Set variables for download, using version variables
user_prompt="Download PCMDI Metrics Package (PMP) version "${pmp_version}"?"
wget_path="https://github.com/PCMDI/pcmdi_metrics/archive/refs/tags/"${pmp_version}".tar.gz"
archive_name="pcmdi_metrics-"${pmp_version_number}

# Download the PMP code to temporary directory
# Variables for strings with spaces must be quoted!
temporary_module_download "${user_prompt}" "${wget_path}"  ${archive_name}

# Since PMP can be installed via conda-forge, we're only going
# to keep the files needed to run CMEC driver.
echo
echo "Copying cmec files to module directory."
cp ${CMEC_TMP_DIR}/$archive_name/contents.json $CMEC_MODULE_DIR
cp -r ${CMEC_TMP_DIR}/$archive_name/cmec $CMEC_MODULE_DIR

# Create PMP conda environment
package_name="PCMDI Metrics Package"
conda_env_name="_CMEC_pcmdi_metrics"
create_command="conda create  -p $CONDA_ENV_DIR/_CMEC_pcmdi_metrics -c conda-forge pcmdi_metrics"

conda_env_from_command_line "$package_name" $conda_env_name "$create_command"

# Define a reusable function for downloading sample data.
# This can then be wrapped in a prompt.
pmp_install_sample_data () {
    conda activate _CMEC_pcmdi_metrics
    mkdir $CMEC_MODULE_DIR/demo_data
    python ${CMEC_TMP_DIR}/$archive_name/doc/jupyter/Demo/download_sample_data.py $CMEC_MODULE_DIR/demo_data
    echo
    echo "Sample data downloaded to "$CMEC_MODULE_DIR/demo_data
}

# Download sample data
if [ $USE_PROMPTS == "1" ]; then
    while true; do
        read -p "Download sample data? [Y/n] "  yn
        case $yn in
            [Nn]* ) echo "Skipping sample data download"
                    break;;
            * ) pmp_install_sample_data
        esac
    done
else
    # Default is to download sample data
    pmp_install_sample_data
fi
