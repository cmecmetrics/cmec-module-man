 #!/bin/bash

internal_update_repository_lines () {
    # Pulling out this code into a function since it's called a couple of times.
    # need default branch name, eg https://davidwalsh.name/get-default-branch-name
    default_branch_name=$(git remote show https://$1/$2 | grep 'HEAD branch' | cut -d' ' -f5)
	git checkout $default_branch_name
    git pull origin $default_branch_name
}

git_update_repository () {
    # Update an existing git repository.
	# Prompt user, or update the repository by default.
    if [ $USE_PROMPTS == "1" ]; then
	    while true; do
		    read -p "Update "$3" directory? [Y/n] "  yn
		    case $yn in
			    [Nn]* ) echo "Skipping repository update"
					    break;;
			    * ) internal_update_repository_lines $1 $2
				    break;;
		    esac
	    done
    else
        # Default is to update the repo
        internal_update_repository_lines $1 $2
    fi
}

# Clone the Drought Metrics code from github
git_clone () {
    #--------------------------------------------
    # Clone a git repository to a folder.
    # Depends on: git_update_repository
    # Args:
    # $1: Git server (e.g. github.com)
    # $2: USER/NAME of repository
    # $3: module name for folder
    #--------------------------------------------
    echo
    echo "The module code will be cloned from:"
    echo "   https://$1/"$2
    #echo "Two options are provided here for cloning the repository."
    #echo "Please choose the option that matches your Github usage."
    echo
    if [ $CMEC_CLONE_HTTPS == "1" ]; then
        git clone -q https://$1/$2.git $3
        ret=$?
    elif [ $CMEC_CLONE_HTTPS == "0" ]; then
        git clone -q git@$1:$2.git $3
        ret=$?
    fi

    # Git clone will fail if we didn't overwrite the module directory
    # before running the recipe. So check for this error and update repo if needed.
    if [ "$ret" -ne 0 ]; then
        if [ -d $3 ]; then
            echo "Module "$3" repository already exists."
            cd $3
            git_update_repository $1 $2 $3
            cd ${CMEC_MODULES_HOME}
        fi
    fi
}

conda_env_exists () {
    #--------------------------------------------
    # Check if a conda environment is listed in conda info text.
    # Return true (found) or false (not found).
    # Args:
    # $1: Full environment name
    #--------------------------------------------
    potential_matches_for_env=($(conda env list | grep $1 | cut -d ' ' -f 1))
    found=0
    for i in "${potential_matches_for_env[@]}"
    do
        if [ "$i" = "$1" ]; then
            found=1
        fi
    done
    echo $found
}

conda_env_from_yaml () {
    #--------------------------------------------
    # Create conda environments from one or more yaml files.
    # Args:
    # $1: module name
    # $i: yaml location relative to module directory
    #--------------------------------------------
    echo
    if [ $USE_PROMPTS == "1" ]; then
        echo "$1 requires 1 or more conda environment for use."
        while true; do
	        read -p "Install $1 conda environments? [Y/n] " yn
	        case $yn in
		        [Nn]* ) echo "Skipping conda environments for "$1"."
				        echo "Conda environment can be created manually using:"
                        for i in "${@:2}"
                        do
				            echo "% conda env create -y -p $CONDA_ENV_DIR -f $CMEC_MODULE_DIR/$i"
                        done
				        exit;;
		        * ) break;; #continue to next section for install
	        esac
        done
    else
        echo "Creating conda environments for "$1"."
    fi

    # Create environments from file
    for i in "${@:2}"
    do
        # Pull conda environment name from yaml file
        tmp_conda_env_name=$(grep "name:" $CMEC_MODULE_DIR/$i | cut -d" " -f2)

        if [ $(conda_env_exists $tmp_conda_env_name) -eq 1 ]; then
            echo "Environment "$tmp_conda_env_name" already exists."

            # Prompt to remove existing environments, or delete by default
            if [ $USE_PROMPTS == "1" ]; then
                while true; do
                    read -p "Remove existing environment "$tmp_conda_env_name"? [Y/n] " yn
                    case $yn in
                        [Nn]* ) break;;
                        *)      echo "Running conda env remove for "$tmp_conda_env_name
                                conda env remove --name $tmp_conda_env_name
                                break;
                    esac
                done
            else
                echo "Running conda env remove for "$tmp_conda_env_name
                conda env remove --name $tmp_conda_env_name
            fi
        fi

        # Run create; if it fails, skip this environment
        conda env create -y -p $CONDA_ENV_DIR/$tmp_conda_env_name -f $CMEC_MODULE_DIR/$i || 
        echo "Skipping conda environment $i."
    done
}

conda_env_from_command_line () {
    #--------------------------------------------
    # Create a conda environment from a 
    # conda create command passed to the function.
    # Args:
    # $1: Full package name
    # $2: Conda env name
    # $3: Conda install command 
    #     (eg "conda create -n name -c channel args")
    #     tip: if passing $3 by a variable, quote the 
    #          variable since the command contains spaces
    #--------------------------------------------
    echo
    if [ $USE_PROMPTS == "1" ]; then
        echo "$1 requires 1 conda environment."
        echo "If you do not have the "$2" conda environment, it can be created now."
        while true; do
	        read -p "Install PMP conda environment? [Y/n] " yn
	        case $yn in
		        [Nn]* ) echo "Skipping conda environments for $1."
				        break;;
		        * )     # Create conda environments
                        eval "$3";
                        break;;
	        esac
        done
    else
        echo "Creating conda environment for "$1
        # Create conda environments by default
        eval "$3"" -y"
    fi
}

temporary_module_download () {
    #--------------------------------------------
    # Download release to temporary location.
    # Args:
    # $1: prompt question
    # $2: path
    #--------------------------------------------
    if [ $USE_PROMPTS == "1" ]; then
        while true; do
	        read -p "$1"" [Y/n] " yn
	        case $yn in
		        [Nn]* ) echo "Exiting without installation"
                        echo "CMEC driver cannot register module without download."
                        exit;;
		        * )     # Default case is to continue to download
                        # instead of exiting 
                        break;;
	        esac
        done
    fi

    # If no prompt, or user chooses anything except "n", 
    # continue with download
    echo "Downloading module"
    wget -q -P ${CMEC_TMP_DIR} $2; ret=$?
    if [ "$ret" -ne 0 ]; then
        echo "Error in wget. Could not download module release."
        echo "Exiting."
        exit
    fi
    tmp_archive_name=$(echo $2 | cut -d '/' -f 9)
	tar -xf ${CMEC_TMP_DIR}/$tmp_archive_name -C ${CMEC_TMP_DIR}

}

module_download () {
    #--------------------------------------------
    # Download release to module folder and clean up.
    # Args:
    # $1: prompt question
    # $2: path
    # $3: archive name
    #--------------------------------------------
    if [ $USE_PROMPTS == "1" ]; then
        while true; do
	        read -p "$1" "[Y/n] " yn
	        case $yn in
		        [Nn]* ) echo "Exiting without installation"
                        echo "CMEC driver cannot register module without download."
                        exit;;
                * )     # continue to download
                        break;;
	        esac
        done
    fi

    # If no prompt, or user chooses anything except "n", 
    # continue with download
    echo "Downloading module"
    wget -P $CMEC_MODULES_HOME $2; ret=$?
    if [ "$ret" -ne 0 ]; then
        echo "Error in wget. Could not download module release."
        echo "Exiting."
        exit
    fi
    tmp_archive_name=$(echo $2 | cut -d '/' -f 9)
    rm -rf $CMEC_MODULE_DIR
	tar -xf $CMEC_MODULES_HOME/$tmp_archive_name -C $CMEC_MODULES_HOME
    # If extracted archive name is not the same as the module name:
    if [ ! -d $CMEC_MODULE_DIR ]; then
        mv $CMEC_MODULES_HOME/$3 $CMEC_MODULE_DIR
    fi
    rm $CMEC_MODULES_HOME/$tmp_archive_name

}

get_latest_repository_tag () {
    #--------------------------------------------
    # Return the latest tag found in a git repository.
    # If curl is not available, use the default.
    # Args:
    # $1: USER/REPOSITORY
    # $2: Default
    #--------------------------------------------
    # Helpful resource: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
    which curl &> /dev/null # check if curl installed
    ret=$?
    if [ "$ret" -ne 0 ]; then
        echo $2
    else
        echo $(curl  -s "https://api.github.com/repos/"$1"/releases/latest"  \
	    | grep "tag_name"  \
	    | cut -d '"' -f 4)
    fi
}

conda_pip_install () {
    #--------------------------------------------
    # Run a pip install command in a module 
    # directory and a conda environment.
    # Depends on: conda_env_exists
    # Args:
    # $1: Module name
    # $2: Conda environment name
    #--------------------------------------------
    if [ $(conda_env_exists $2) -eq 1 ]; then
        echo "Installing "$1" in conda environment"
	    cd $1
	    source $CONDA_SOURCE
	    conda activate $2
	    pip -q install .
	    conda deactivate
    else
	    echo
	    echo "*****************************************************"
        echo "Conda environment "$2" not found."
	    echo "To install "$1" in a conda environment manually,"
	    echo "enter the "${CMEC_MODULE_DIR}${1}" directory and do:"
        echo "'conda activate your_environment'"
	    echo "'pip install .'"
	    echo "*****************************************************"
    fi
}

conda_setup_py_install () {
    #--------------------------------------------
    # Run a setup.py command in a module 
    # directory and conda environment.
    # Depends on: conda_env_exists
    # Args:
    # $1: Module name
    # $2: Conda environment name
    #--------------------------------------------
    if [ $(conda_env_exists $2) -eq 1 ]; then
        echo "Installing "$1" in conda environment"
	    source $CONDA_SOURCE
	    conda activate $2
	    python setup.py -q install
	    conda deactivate
    else
	    echo
	    echo "*****************************************************"
        echo "Conda environment "$2" not found."
	    echo "To install "$1" in a conda environment manually,"
	    echo "enter the "${CMEC_MODULE_DIR}${1}" directory and do:"
        echo "'conda activate your_environment'"
	    echo "'python setup.py install'"
	    echo "*****************************************************"
    fi
}
