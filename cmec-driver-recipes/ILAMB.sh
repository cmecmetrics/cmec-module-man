#!/bin/bash

# This script walks through the steps for installing ILAMB
# for use with CMEC driver.

# import some standard functions
source cmec-driver-recipes/bash_helper_functions.sh

ilamb_version="2.6"

# Set variables for download, using version variables
user_prompt="Download ILAMB version "${ilamb_version}"?"
wget_path="https://github.com/rubisco-sfa/ILAMB/archive/refs/tags/"v${ilamb_version}".tar.gz"
archive_name=v${ilamb_version}.tar.gz

# Download the ILAMB code to temporary directory
# Variables for strings with spaces must be quoted!
temporary_module_download "${user_prompt}" "${wget_path}"  ${archive_name}

# Copy only the needed files to ILAMB folder
echo
echo "Copying cmec files to module directory."
module_dir=$CMEC_MODULE_DIR
cp $CMEC_TMP_DIR/ILAMB-${ilamb_version}/contents.json ${module_dir}
cp -r $CMEC_TMP_DIR/ILAMB-${ilamb_version}/cmec-driver ${module_dir}

# Create ILAMB conda environment
package_name="ILAMB"
conda_env_name="ilamb"
create_command="conda create -p "$CONDA_ENV_DIR"/ilamb -c conda-forge ILAMB"

conda_env_from_command_line "$package_name" $conda_env_name "$create_command"
