# This script scrapes the team_ids from all scorecard configurations, and updates the master SQL file accordingly

from jinja2 import Template
from jinja2 import Environment, FileSystemLoader
from get_team_ids import concatenate_team_ids
import os

sql_file_path = os.path.expanduser(r"~\automation_scorecard\sql_templates")
sql_env = Environment(loader=FileSystemLoader(sql_file_path))
new_sql_config_path = os.path.expanduser(r"~\automation_scorecard\new_sql_configs")

sql_files = ['camp_monthly','cp_monthly','p_monthly','placement_monthly','team_sql']

config_path = os.path.expanduser(r"~\automation_scorecard\configs")
d = []
for (dirpath, dirnames, filenames) in os.walk(config_path):
    d.extend(dirnames)
    break

def generate_sql_template(sql_env,sql_file,config_path,filenames):
	try:
		test_template = sql_env.get_template('%s.sql' % sql_file )
	except TemplateNotFound:
		raise RuntimeError('Unable to find following SQL file: ' + sqlfile)

	#below arguments need to pull in from get_team_ids.py
	args_dict = {'team_ids': concatenate_team_ids(config_path,filenames)}
	return test_template.render(args_dict)

def generate_all_sql_templates(new_sql_config_path,sql_env,sql_file,config_path,filenames):
	

	with open(os.path.join(new_sql_config_path,(sql_file + '.sql')),'w') as new_sql_file:
		update_sql_template = generate_sql_template(sql_env,sql_file,config_path,filenames)
		new_sql_file.write(update_sql_template)

	new_sql_file.close()

for sql_file in sql_files:
	generate_all_sql_templates(new_sql_config_path,sql_env,sql_file,config_path,filenames)




# test to see if above code works
# table_sql = test_template.render(args_dict)
# print table_sql