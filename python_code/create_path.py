import os


#What does this do?
#create_config_file_path takes in a file name and then based on the file name, it creates a directory for the raw data if it doesn't already exist
#this is called in split_master_3.py so that the data for each report is organized into one folder

def create_config_file_path(file):
	jobs_path = os.path.expanduser(r"~\automation_scorecard\configs")
	write_raw_data_path = os.path.expanduser(r"~\automation_scorecard\raw_data")

	file = str(file).replace('.yaml','_raw')
	new_path = os.path.join(write_raw_data_path,file)
	
	if not os.path.exists(new_path):
		os.makedirs(new_path)
	else:
		return new_path

	print new_path + " has been created"
	return new_path


'''

# Just a test function I used to develop our main function

def create_config_file_path_test():
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
'''