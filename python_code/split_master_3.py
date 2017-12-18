#This program reads in a file name from the user and then creates new csv files based on unique team IDs
#Can be used to break down a large CSV file which won't open in Excel
#Currently being imported into report_auto.py


import os
import csv


def split(config,current_file,raw_type,cadence):
	#define lists
	unique_teams = []
	team_ids = []
	team_counter=0
	#currentFile = raw_input('Enter name of file to split: ')
	
	#Change currentFile Manually
	#current_file = 'france_cp.csv'
	
	#read file
	
	f = open(current_file,'rb')
	file = csv.reader(f)
	#next(f) #skip header files

	#take distint list of team ids
	for row in file:
		
		if row[0] not in unique_teams:
			unique_teams.append(row[0])
	
	#print unique_teams - upper portion of code works as intended
	
	
	for k,v in config.iteritems():

		team_ids = str(v).split(',') #yaml treats single id like an int so we want to cast it as a string

		f = open(current_file,'rb')
		file = csv.reader(f)
		next(f)
		#os.chdir("")
		with open(k + "_" + raw_type + ".csv",'wb') as writefile:
			writer = csv.writer(writefile, delimiter=',')
		
			for line in file:
				for team in team_ids:
					if str(line[0])  == str(team):
						writer.writerow(line)
			#os.chdir("")
		
			for line in file:
				if str(line[0]) == str(team_ids):
					writer.writerow(line)
		f.close()
				

	f.close()
