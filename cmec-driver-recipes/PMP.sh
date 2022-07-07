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

