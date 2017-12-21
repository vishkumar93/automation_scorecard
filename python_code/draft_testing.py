'''
we need to find a way for each report configuation to create a folder for each set of raw data


for config in configs:
	create folder


'''

import os

def create_config_file_path():
	jobs_path = os.path.expanduser(r"~\automation_scorecard\configs")
	d = []
	for (dirpath, dirnames, filenames) in os.walk(jobs_path):
	    d.extend(dirnames)
	    break

	for file in filenames:
		file = str(file).replace('.yaml','_raw')
		newpath = os.path.join(jobs_path,file)
		
		if not os.path.exists(newpath):
			os.makedirs(newpath)

		print newpath + " has been created"

# all we're gonna do here is call this function for the file specifically, use that new path as the write path and write each set of files for that config in there
