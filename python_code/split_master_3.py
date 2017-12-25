#This program reads in a file name from the user and then creates new csv files based on unique team IDs
#Can be used to break down a large CSV file which won't open in Excel
#Currently being imported into report_auto.py


import os
import csv
from create_path import create_config_file_path

#config is a dict
#file is file name of configuration

''' Below function takes in 5 paramaters: 

file: file name of yaml configuration
config: this the parsed output of the yaml file, which is a dict
master_file: user inputs a name of the raw data needed to be parsed
raw_type: user inputs the type of raw file (c,p,cp,p,t)
cadence: user inputs the cadence of reports (m,q for monthly or quarterly)

'''

def split(file,config,master_file,raw_type,cadence): 
	#define lists
	unique_teams = [] #unique teams from csv file
	team_ids = [] #unique team ids from yaml
	team_counter=0

	#file paths to be utilized in function
	excel_file_path = os.path.expanduser(r"~\automation_scorecard\excel_files")
	write_file_path = create_config_file_path(file) #function returns file path
	jobs_path = os.path.expanduser(r"~\automation_scorecard\configs")
	
	
	#read file
	f = open((os.path.join(excel_file_path,master_file)),'rb')
	file = csv.reader(f)
	#next(f) #skip header files
	header = next(file)

	#take distint list of team ids
	for row in file:
		
		if row[0] not in unique_teams:
			unique_teams.append(row[0])

	
	for k,v in config.iteritems():

		team_ids = str(v).split(',') #yaml treats single id like an int so we want to cast it as a string
		team_ids = set(team_ids)

		f = open((os.path.join(excel_file_path,master_file)),'rb')
		file = csv.reader(f)

		
		#os.chdir("")
		write_file_name = k + "_" + raw_type + ".csv"
		

		with open((os.path.join(write_file_path,write_file_name)),'wb') as writefile:
			writer = csv.writer(writefile, delimiter=',')
			
			#below writers header into csv file
			writer.writerow(header)

			for line in file:
				for team in team_ids:
					if str(line[0])  == str(team):
						writer.writerow(line)
			#os.chdir("")
		
			for line in file:
				if str(line[0]) == str(team_ids):
					writer.writerow(line)

		print "The data for " + str((k + "_" + raw_type + ".csv")) + " has been generated"

		f.close()
				
			

	f.close()



split('digitas_amex.yaml',{'digitas_amex': '30'},'sample_camp.csv','c','m')