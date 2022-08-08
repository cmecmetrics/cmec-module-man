#!/bin/bash/python
"""
setup_module.py

This script runs the recipe for a given cmec module
and manages the temporary and module directories.

Arguments:
    module: Name of CMEC module to install
    tmp_dir: Path to temporary directory (optional)
             This directory will be deleted after use.
             Default: ./tmp_modules
    module_dir: Name of directory to save modules in (optional)
                Default: ./modules
"""
import argparse
import json
import os
import shutil
import sys
import subprocess

def user_prompt(question, default = "yes"):
    """Asks the user a yes/no question

    Args:
        question (str): Question for the user
    """
    prompt = '[Y/n] '
    valid = {"yes": True, "y": True, "no": False, "n": False}

    while True:
        sys.stdout.write(question + " " + prompt)
        choice = input().lower()
        if choice == '':
            return valid[default]
        if choice in valid:
            return valid[choice]
        sys.stdout.write("Please respond 'y' or 'n' ")

def check_user_settings():
    # Check for saved conda environment and git information
    user_settings_file = ".module_manager_user_settings"

    # If file doesn't exist, create a blank version
    if not os.path.exists(user_settings_file):
        with open(user_settings_file,"w") as open_user_settings:
            json.dump({}, open_user_settings)

    try:
        with open(user_settings_file, "r") as open_user_settings:
            user_settings = json.load(open_user_settings)
    except json.decoder.JSONDecodeError:
        print("Could not load user settings JSON.")
        print("Please check for JSON format errors.")
        user_settings = {}

    # Generate guesses for where conda installation is
    cmd = ["conda", "info", "--base"]
    conda_base = subprocess.run(cmd, capture_output=True).stdout.decode("utf-8").strip("\n") 
    conda_env_guess = os.path.join(conda_base,"envs")
    conda_source_guess = os.path.join(conda_base,"etc/profile.d/conda.sh")

    # Flag to track if any settings are changed on-the-fly
    edited = False

    # Check key for using https or ssh clone for git.
    if ("git_clone_https" not in user_settings) or \
    (not isinstance(user_settings["git_clone_https"],bool)):
        print("Setting git clone method to default: https")
        user_settings["git_clone_https"] = True
        edited = True

    # Check if the sample data directory has been set
    if "sample_data_dir" not in user_settings:
        print("Setting sample data directory to ./sample_data")
        user_settings["sample_data_dir"] = "./sample_data"
        edited = True

    # Check conda environment keys, first using guess.
    for item, guess in zip(["conda_source_file", "conda_env_dir"], [conda_source_guess, conda_env_guess]):
        if (item not in user_settings) or (user_settings[item] == ""):
            print("Setting ",item," not found in user settings.")
            if os.path.exists(guess):
                    sys.stdout.write("Use " + guess + " as " + item + "? [Y/n] ")
                    choice = input()
                    if choice != 'n':
                        user_settings[item] = guess
                        edited = True

    # If the user didn't want to use the guesses, let them input their own settings.
    for item in (["conda_source_file", "conda_env_dir"]):
        if (item not in user_settings) or (user_settings[item] == ""):
            while True:
                sys.stdout.write("Please provide a value for " + item + ": ")
                result = input()
                if os.path.exists(result):
                    user_settings[item] = result
                    edited = True
                    break
                else:
                    print("The file or directory " + result + " was not found.")
                    print("Please enter a valid path")
        user_settings[item] = os.path.expanduser(user_settings[item])

    # Give the option of writing any edited settings back to the file.
    if edited == True:
        sys.stdout.write("Write new settings to file? [Y/n] ")
        result = input()
        if result != 'n':
            print("Writing settings to " + user_settings_file)
            with open(user_settings_file, "w") as open_user_settings:
                json.dump(user_settings, open_user_settings, indent=4)

    return user_settings

if __name__ == "__main__":
    
    print("\n*****Starting CMEC Module Manager*****")
    
    # Set default directories
    module_dir = os.path.abspath("./modules")
    tmp_dir = os.path.join(os.path.abspath("./tmp_modules"),"")

    # User settings
    parser = argparse.ArgumentParser()
    parser.add_argument("module",
                        help="Module name",
                        type=str)
    parser.add_argument("--tmp_dir",
                        help="Temporary directory path (will be deleted)",
                        default=tmp_dir,
                        type=str)
    parser.add_argument("--module_dir",
                        help="CMEC modules root directory",
                        default=module_dir,
                        type=str)
    parser.add_argument("--force",
                        help="Do full installation by default",
                        action='store_true')
    args = parser.parse_args()
    
    # Get module name and directories
    module = args.module
    recipe_dir = "./cmec-driver-recipes"
    mod_file = os.path.join(recipe_dir,module+".sh")
    
    module_dir = os.path.join(args.module_dir,module,"")
    tmp_dir = args.tmp_dir
    
    # Look for module recipe    
    if os.path.exists(mod_file):
        # Ask to run module recipe
        if args.force:
            run_recipe = True
        else:
            run_recipe = user_prompt("Run {0} recipe?".format(module))
    else:
        print("Recipe for module " + module + " not found.")
        print("Please check that module name is correct.")
        print("If module name is correct, try " +
              "updating repository with:")
        print("%  git pull origin master")
        sys.exit()
    
    if run_recipe:
        # Ask to overwrite module_dir
        overwrite = True
        if os.path.exists(module_dir) and not args.force:
            overwrite = user_prompt(
                "Overwrite directory {0}?".format(module_dir))
        
        if overwrite:
            if os.path.exists(module_dir):
                shutil.rmtree(module_dir)
        else:
            print("Skip overwrite. This could result in "+
                  "unexpected behavior.\n")
        
        for folder in ["./modules",module_dir,tmp_dir]:
            if not os.path.exists(folder):
                os.mkdir(folder)

        cmec_user_settings = check_user_settings()

        # Check that sample data directory exists
        sample_dir = os.path.abspath(cmec_user_settings["sample_data_dir"])
        if not os.path.exists(sample_dir):
            os.mkdir(sample_dir)

        # Set environment variables for recipe to use
        run_env = os.environ.copy()
        run_env["CMEC_MODULES_HOME"] = os.path.abspath(args.module_dir)
        run_env["CMEC_MODULE_DIR"] = module_dir
        run_env["CMEC_TMP_DIR"] = tmp_dir
        run_env["USE_PROMPTS"] = str(int(args.force == False))
        run_env["CONDA_ENV_DIR"] = cmec_user_settings["conda_env_dir"]
        run_env["CONDA_SOURCE"] = cmec_user_settings["conda_source_file"]
        run_env["CMEC_CLONE_HTTPS"] = str(int(cmec_user_settings["git_clone_https"] == True))
        run_env["CMEC_DATA_DIR"] = os.path.join(sample_dir,module)
        
        # Run module recipe
        print("\nRunning recipe for ",module)
        try:
            subprocess.run(["sh",mod_file],
                           shell=False,
                           env=run_env,
                           check=True)
        except subprocess.CalledProcessError as err:
            print("\nError in",mod_file,". Exiting.")
            sys.exit()

        # Run unregister in case old module registration 
        # is present
        print("\nRemoving existing module registration "+
              "from CMEC library if present")
        try:
            subprocess.run(["cmec-driver","unregister",module],
                           shell=False,
                           check=True,
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError:
            pass

        # Register with cmec-driver
        print("\nRegistering module",module)
        try:
            subprocess.run(["cmec-driver","register",module_dir],
                           shell=False,
                           check=True,
                           text=True,
                           input="y",
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.STDOUT)
            print("Module",module,"successfully registered")
        except subprocess.CalledProcessError:
            print("\nError in cmec-driver. " +
                  "Could not register module",module)
            print("Please verify that module CMEC files were successfully installed in")
            print("module directory: ",module_dir)
            print("If module is already registered try:\n" +
                  "    cmec-driver unregister " + module)
            print("To register by hand try:\n" +
                  "    cmec-driver register " + module_dir)

        # Remove temporary directory
        if os.path.exists(tmp_dir):
            shutil.rmtree(tmp_dir)
    else:
        print("\nSkipping run recipe for module",module)
        print("Exiting")
    # Download obs?
