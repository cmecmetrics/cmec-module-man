CMEC Module Manager
===================

What does the module manager do?
--------------------------------

The module manager script runs installation scripts for CMEC modules. The installation script is different for each module, depending on how the module is distributed. Usually, module source code needs to be downloaded and conda environments need to be created.  

Module code is saved to cmec-module-man/modules (unless the user provides a different directory). In some cases, the module can be efficiently installed from an Anaconda channel using the conda command, so only the required CMEC files are saved from the code base (e.g. contents.json). In other cases, the entire module source code is downloaded and saved. When possible, the latest release is installed, but some code bases are simply cloned from Github.

Most CMEC modules run Python scripts that require specific conda environments. The installation script also includes commands for creating these environments. When running the module manager for the first time, users will be prompted for information about their conda environment.

Environment
-----------
This software is intended for Unix-like and MacOS operating systems.

The python package dependencies are cmec_driver (from conda-forge) and python>=3.5. 

Conda is required as most modules use conda environments to manage python dependencies.  

Here are example commands to create and activate a new conda environment called "cmec" for running the module manager:  
```
conda create -n cmec -c conda-forge cmec_driver python=3.9
conda activate cmec
```
The curl utility is optional but is recommended for best performance. The git and wget utilities are required, but are standard on many operating systems.

Settings
--------

The setup script requires a few user settings. It will attempt to set these automatically on the first run, or you can create a settings file ahead of time.

Copy .module_manager_user_settings-example to .module_manager_user_settings. 
```
cp .module_manager_user_settings-example .module_manager_user_settings
```

This file uses JSON formatting. Use a text editor to complete the settings and save your choices. The settings keys are described in the following section.  

### Settings file keys

**git_clone_https**  
Boolean true (default) or false. Set true to use https for cloning, or false to use ssh for cloning. Do not capitalize or quote this value.

**conda_env_dir**  
String. In the quotes, enter the path to the directory used for storing your conda environments. For example, in miniconda 3 this might be: ~/miniconda3/envs. Your system might have a different environment location, so please consult any documentation about using conda on your platform. The setup script can expand the tilde in the path.

**conda_source_file**  
String. In the quotes, enter the path to the file that gets "sourced" to activate conda. For example, in miniconda 3 this might be: ~/miniconda3/etc/profile.d/conda.sh. Your system might have a different source script, so please consult any documentation about using conda on your platform. The setup script can expand the tilde in the path.  

**sample_data_dir**  
String. This is a directory for sample data storage. Packages that include large datasets will download those datasets to a subfolder in this directory. Ideally this is a location with multiple gigabytes of space. Users will be prompted before large datasets are downloaded.  

Usage
------
Run the setup_module.py script following the example below. Replace the final 'module' argument with the short name of the target module (see Table 1 below).
```
python setup_module.py <module>
```
You will be prompted throughout the installation process (unless the --force option is invoked). It is recommended that you overwrite existing directories and install any required conda environments; however, flexibility is offered for cases where that is not ideal.

### Options 
--module_dir  
Directory of the code for the specified module. Default is cmec-module-man/modules/.  

--tmp_dir  
Temporary workspace that will be deleted after the installation. Default is cmec-module-man/tmp_modules.  

--force  
Run complete (default) installation without prompts

### Table 1. Supported CMEC modules

| Short name | Long name | Project code |
| ---------- | --------- | ------------- |
| ASoP | Analyzing Scales of Precipitation | https://github.com/nick-klingaman/ASoP |
| CMECTEST | Example CMEC module | https://github.com/cmecmetrics/example_cmec_module |
| Drought_Metrics | Drought Metrics | https://github.com/cmecmetrics/Drought_Metrics |
| ILAMB | International Land Model Benchmarking | https://github.com/rubisco-sfa/ILAMB |
| MDTF_Diagnostics | Model Diagnostics Task Force | https://github.com/NOAA-GFDL/MDTF-diagnostics |
| PMP | PCMDI Metrics Package |  https://github.com/PCMDI/pcmdi_metrics |
| XWMT | xWMT (Water Mass Transformation) | https://github.com/cmecmetrics/cmec_xwmt |

 

Updates
-------
To obtain the latest code use:  
```
git checkout main
git pull origin main
```

Contributions
-------------
Brief instructions are provided here to get you started on making a contribution. It is recommended that you create a fork of the cmec-module-man repository on Github and work from a local copy of your fork. Make sure your fork is up-to-date with the original cmec-module-man.

In your local repository, check out a new branch with a unique name (named after your module is ideal):
```
git checkout -b your_new_branch_name
```
Installation workflows are found in the cmec-module-recipes folder. Each module has a shell script that walks through the installation. Enter the recipes directory:   
```
cd cmec-driver-recipes
```
Use the existing recipes and documentation in this folder as references for your own recipe. Create your new recipe and commit your changes:
```
git commit -m "your commit message"
```
Additionally, provide information about your module in Table 1 of this README.

Push changes to your fork and open a pull request.

Issues
------
While these recipes have been tested on Mac and Unix systems, results may be different on your system.

If you encounter any problems, please open an Issue on Github. Describe the operating system you are working on and provide the steps to reproduce your problem. 
  
License
-------
The CMEC module manager is distributed under the terms of the BSD 3-Clause License.

LLNL-CODE-832592  

Acknowledgement
---------------

Software contained in this repository is developed by climate and computer scientists from the Program
for Climate Model Diagnosis and Intercomparison ([PCMDI][PCMDI]) at Lawrence Livermore National
Laboratory ([LLNL][LLNL]). This work is sponsored by the Regional and Global Model Analysis
([RGMA][RGMA]) program, of the Earth and Environmental Systems Sciences Division ([EESSD][EESSD])
in the Office of Biological and Environmental Research ([BER][BER]) within the
[Department of Energy][DOE]'s [Office of Science][OS]. The work is performed under the auspices of
the U.S. Department of Energy by Lawrence Livermore National Laboratory under Contract
DE-AC52-07NA27344.

[PCMDI]: https://pcmdi.llnl.gov/
[LLNL]: https://www.llnl.gov/
[RGMA]: https://climatemodeling.science.energy.gov/program/regional-global-model-analysis
[EESSD]: https://science.osti.gov/ber/Research/eessd
[BER]: https://science.osti.gov/ber
[DOE]: https://www.energy.gov/
[OS]: https://science.osti.gov/
