'''
Requires a yaml configuration file, split_master3.py, and a master raw data csv file
'''

import split_master_3 as sm
import yaml
import os

#store all config file names in list

jobs_path = os.path.expanduser(r"~\automation_scorecard\configs")
d = []
for (dirpath, dirnames, filenames) in os.walk(jobs_path):
    d.extend(dirnames)
    break
		
#Function returns parsed YAML
def parseYaml(scorecard_config,filepath):
    with open((os.path.join(filepath + "/" + scorecard_config)),'rb') as f:
    	return yaml.safe_load(f)

#Apply function to configuration file

master_file = raw_input('Enter name of current scorecard file(i.e: scorecard.csv): ')
raw_type = raw_input('What kind of file is this? (t,c,cp,p,pp) : ' )
cadence = raw_input('What is the cadence? (monthly = m, quarterly = q) :')

for file in filenames:
	scorecard_dict = parseYaml(file,jobs_path)
	sm.split(file,scorecard_dict,master_file,raw_type,cadence)

'''
Enter paramters of config into split_master function

yaml is a dict, so we can pass this through the split function
'''