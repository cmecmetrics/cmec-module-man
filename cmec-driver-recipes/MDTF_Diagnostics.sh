#!/bin/bash

source cmec-driver-recipes/bash_helper_functions.sh

mdtf_version=3.0-beta.3

# Set variables for download, using version variables
user_prompt="Download MDTF Diagnostics version "${mdtf_version}"? "
wget_path="https://github.com/NOAA-GFDL/MDTF-diagnostics/archive/refs/tags/v"${mdtf_version}".tar.gz"
archive_name="MDTF-diagnostics-"${mdtf_version}

# Download the MDTF release
# Variables for strings with spaces must be quoted!
module_download "${user_prompt}" "${wget_path}"  ${archive_name}

# Write contents.json
echo
echo "Creating contents.json"
python generate_contents.py modules/MDTF_Diagnostics modules/MDTF_Diagnostics/diagnostics MDTF_Diagnostics "MDTF Diagnostics package version "${mdtf_version}

CONDA_ROOT=$(conda info --base)

echo
echo "***************************INFO***************************"
echo "MDTF Diagnostics would like to install conda environments."
echo "If you have not previously installed these environments,"
echo "it is recommended you do so now."
echo
echo "Otherwise, to install conda environments manually,"
echo "go to ./modules/MDTF_Diagnostics and run:"
echo "%  ./src/conda/conda_env_setup.sh --all --conda_root \$CONDA_ROOT --env_dir \$CONDA_ENV_DIR"
echo "(substituting your paths for \$CONDA_ROOT and \$CONDA_ENV_DIR.)"
echo
echo "More documentation is available at:"
echo "https://github.com/NOAA-GFDL/MDTF-diagnostics"
echo "***********************END INFO***************************"
echo
sleep .5
while true; do
	read -p "Install MDTF conda environments (see INFO above)? [y/n] " yn
	case $yn in
		[Yy]* ) break;; #continue to next section for install
		[Nn]* ) echo "Skipping conda environments for MDTF Diagnostics.";
				exit;;
		* ) echo "Please answer yes (y) or no (n).";;
	esac
done

# Call the MDTF script for conda environment install
cd $CMEC_MODULE_DIR
./src/conda/conda_env_setup.sh --all --conda_root $CONDA_ROOT --env_dir $CONDA_ENV_DIR
