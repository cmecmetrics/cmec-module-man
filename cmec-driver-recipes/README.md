Module Manager Recipes
======

What are the recipe scripts?
-----------
Each module has one recipe file, which is named after the module. This is a bash script that contains all the instructions for installing the module. A recipe is called by the setup_module.py script.

Creating a recipe script
------------------------
------------------------

Environment Variables
---------------------

Several environment variables are provided for referencing different installation locations from the recipe file. 

$CMEC_MODULES_HOME  
Directory containing all of the CMEC module codes. Default is cmec-module-man/modules.  

$CMEC_MODULE_DIR  
Directory of the code for the specified module. Default is cmec-module-man/modules/module_name. 

$CMEC_TMP_DIR  
Temporary workspace that will be deleted after the installation. Default is cmec-module-man/tmp_modules.

$USE_PROMPTS  
1 to prompt, 0 for no prompts. Default is 1.  

$CONDA_ENV_DIR  
Directory for storing conda environments. 


Utilities
---------
Most recipe files use a set of standard functions that can be imported from bash_helper_functions.sh. These functions wrap other commands such as git clone or conda create to add prompts and file management. **

The available functions are documented here. All arguments are positional arguments.

To use these functions inside a recipe, add the following line of code to your file before calling the functions:  
`source cmec-driver-recipes/bash_helper_functions.sh`

**git_clone**  
Clone a git repository to a folder inside the current directory. If the repository already exists in that destination, the repository will be updated instead.

Arguments
1. server: The server containing your repository, e.g. "github.com"
2. user/name: The user and repository name for package, e.g. "cmecmetrics/example_cmec_module". Essentially the path to the git repository on the server, minus the final ".git".  
3. module name for folder: This should typically be the same as the module name  

Example usage
```
module_name="ASoP"
repo_name="nick-klingaman/ASoP"
cd $CMEC_MODULES_HOME
git_clone $repo_name $module_name   
```

**conda_env_from_yaml**  
Create conda environments from one or more yaml files.

Arguments  
1. module name used for display purposes  
2. yaml file name(s) relative to module directory $CMEC_MODULE_DIR  

Example usage
```
conda_env_from_yaml $module_name $yaml_file_1 $yaml_file_2
```

**conda_env_from_command_line**   
Create a conda environment from a conda create command passed to the function.

Arguments
1. Full package name: Used for display purposes  
2. Conda env name: This should match the conda environment being manipulated in the conda install command  
3. Conda install command: A conda create command (eg "conda create -n name -c channel args")  

Example usage
```
package_name="ILAMB"
conda_env_name="ilamb"
create_command="conda create -p "$CONDA_ENV_DIR"/ilamb -c conda-forge ILAMB"
conda_env_from_command_line "$package_name" $conda_env_name "$create_command"
```
    
Tip: when passing the first or third arguments by reference, quote the variable since the strings may contain spaces.

**temporary_module_download**  
Download release to temporary location.

Arguments  
1. prompt: A descriptive string used to prompt the user before download.  
2. path: The url for the tar file to download.  

Example usage
```
user_prompt="Download PCMDI Metrics Package (PMP) version "${pmp_version}"?"
wget_path="https://github.com/PCMDI/pcmdi_metrics/archive/refs/tags/"${pmp_version}".tar.gz"

temporary_module_download "${user_prompt}" "${wget_path}"
```

**module_download**  
Use wget to download a tagged release to the module folder and clean up archive files.

Arguments   
1. prompt: A descriptive string used to prompt the user before download.  
2. path: The url for the tar file to download.  
3. archive name: The file name of the archive that is downloaded.  

Example usage
```
user_prompt="Download MDTF Diagnostics version "${mdtf_version}"? "
wget_path="https://github.com/NOAA-GFDL/MDTF-diagnostics/archive/refs/tags/v"${mdtf_version}".tar.gz"
archive_name="MDTF-diagnostics-"${mdtf_version}

module_download "${user_prompt}" "${wget_path}"  ${archive_name}
```

Tip: when passing the first or second arguments by reference, quote the variable since the strings may contain spaces.

**get_latest_repository_tag**  
Return (via "echo") the latest tag found in a repository on Github. 

Arguments  
1. user/name: The Github user and repository name for package, e.g. "cmecmetrics/example_cmec_module"  
2. default: A default version to use in the event that the curl command is not available to check for the latest.

Example usage
```
pmp_version="$(get_latest_repository_tag "PCMDI/pcmdi_metrics" "2.2.1")"
```

Tip: The "$()" notation is used to convert the echoed result into a variable.

**conda_pip_install**  
Run a pip install command in a module directory and conda environment. This should be run from within the code directory of the package to install.

Arguments  
1. Module name: Used for display purposes.  
2. Conda environment name: Name of the conda environment to install the package in.  

Example usage
```
cd $CMEC_MODULE_DIR
conda_pip_install "$module_name" $conda_env_name
```

**conda_setup_py_install**  
Run a setup.py command in a module directory and conda environment. This should be run from within the code directory containing the setup.py file.

Arguments  
1. Module name: Used for display purposes.  
2. Conda environment name: Name of the conda environment to install the package in.  

Example usage
```
cd $CMEC_MODULE_DIR
conda_setup_py_install "$module_name" $conda_env_name
```
