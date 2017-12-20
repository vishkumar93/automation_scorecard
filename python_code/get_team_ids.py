'''
Loop through configs, parse team id parameter and store all team ids in a list, which gets returns by the 
concatenate_team_ids() function

'''

import os
import yaml


team_id_list = []

config_path = os.path.expanduser(r"~\automation_scorecard\configs")
d = []
for (dirpath, dirnames, filenames) in os.walk(config_path):
    d.extend(dirnames)
    break

def parse_yaml(scorecard_config,file_path):
	with open(os.path.join(file_path + "/" + scorecard_config), 'rb') as f:
		return yaml.safe_load(f)

def retrieve_team_ids(scorecard_config,file_path):
	scorecard_dict = parse_yaml(scorecard_config,file_path)
	for k,v in scorecard_dict.iteritems():
		#returns string to append to team_ids_list and enable team_ids to join as one giant string output
		return str(v) 


def concatenate_team_ids(file_path,filenames):
		team_id_list = []
		for file in filenames:
			team_ids = retrieve_team_ids(file,config_path)
			team_id_list.append(team_ids)

		return ",".join(team_id_list)


#returns joined list of team_ids that will get inserted into query
concatenate_team_ids(config_path,filenames)
	

''' Troubleshooting and using above functions to view each file parameters for future 

Use the first parse_yaml and retrieve_team_id function to ouput k,v for each config file if I ever need a list of active
queries

'''