'''
Requires a yaml configuration file, split_master.py, xlwings_prac.py(in the future) and a master raw data csv file
'''

import split_master
import yaml
import os
import xlwings_prac

#store all config file names in list
jobs_path = 'C:\Python27\configs'
d = []
for (dirpath, dirnames, filenames) in os.walk(jobs_path):
    d.extend(dirnames)
    break
		
#Function returns parsed YAML
def parseYaml(scorecard_config,filepath):
    with open((os.path.join(filepath + "/" + scorecard_config)),'rb') as f:
    	return yaml.safe_load(f)

#Apply function to configuration file

for config_file in filenames:
	scorecard_dict = parseYaml(config_file,jobs_path)
	split_master.split(scorecard_dict)

'''
Enter parameters of config into split_master function

yaml is a dict, so we can pass this through the split function
'''