#!/bin/bash/python
"""
generate_contents.py
Create a contents.json file for a module code base
that is lacking one. This allows the code to be 
registered as a single module with cmec-driver.

Arguments:
	code_root: Code root directory in the "modules" folder
	configuration_root: Root directory of the configuration codes
	module_name: Name of module to write to contents.json
	long_name: Long name for contents.json
"""

import glob
import json
import os
import sys

code_root = sys.argv[1]
configuration_root = sys.argv[2]
module_name = sys.argv[3]
long_name = sys.argv[4]

settings_list = []

# Get paths to settings files and place in list
for file in os.listdir(configuration_root):
	if os.path.isdir(os.path.join(configuration_root,file)):
		settings_file = glob.glob(os.path.join(configuration_root,file,"settings.json*"))[0]
		settings_file = os.path.relpath(settings_file,start=code_root)
		settings_list.append(settings_file)

# Create dictionary
module_dict = {"name": module_name, "long_name": long_name}
out_dict = {"module": module_dict, "contents": settings_list}

# Write to contents.json under code_root
with open(os.path.join(code_root,"contents.json"),"w") as out_json:
	json.dump(out_dict, out_json, indent=4)
