import xlwings as xw
import csv
import os

def read_csv_file(csv_file_name):
	raw_data = []
	with open(csv_file_name,'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		#skips header file since we don't need to copy the header in scorecard template
		#we are leaving header in the csv file so that it easier on the end user to use the raw data
		next(reader)
		for row in reader:
			raw_data.append(row)
	return raw_data,csv_file_name


def function_to_export_data_testing():
	#function constants
	scorecard_template_path = os.path.expanduser(r"~\automation_scorecard\excel_files\scorecard_template.xlsx")
	scorecard_finished_file_path = os.path.expanduser(r"~\automation_scorecard\excel_files")
	raw_data_path = os.path.expanduser(r"~\automation_scorecard\raw_data")

	directory_list = []


	#fetch all folders in raw_data_path 
	for (dirpath, dirnames, filenames) in os.walk(raw_data_path):
	    directory_list.extend(dirnames)

	for directory in directory_list:
		raw_data_files_path = os.path.join(raw_data_path,directory)
		#each directory of raw files, represents 1 report. For each of these directories, open an Excel template and do stuff to it
		workbook = xw.Book(scorecard_template_path)

		for (dirpath, dirnames, filenames) in os.walk(raw_data_files_path):
			raw_data_files_list = []
			raw_data_files_list.extend(filenames)
			for raw_data_file in raw_data_files_list:
				raw_file_path = os.path.join(raw_data_files_path,raw_data_file)
				raw_data,csv_file_name = read_csv_file(raw_file_path)
		
			#this is where the function should operate, on the list of files....
			#for reach directory, open a workbook. then for each csv file....ok maybe we need 2 functions here to separate the workflows
			#for each csv in raw data files list, open an excel doc and export data and then at the end close.
			#it will repeat for the next directory in directory_list
		
			#cleaned_file_name = clean_file_name(file_name)

				if 'campaign' in raw_data_file:
					sheet = workbook.sheets['Campaign']
				elif 'partner' in raw_data_file:
					sheet = workbook.sheets['Partner']
				elif 'cp' in raw_data_file:
					sheet = workbook.sheets['Campaign & Partner']
				elif 'team' in raw_data_file:
					sheet = workbook.sheets['Team']

				# skip the header row and starts at the 16th row since that is where the scorecard reports begin
				# max_row is used for a while loop, which will terminate once all the rows in our csv are read
				# data_row is used for iteration and begins at 1 to skip the header
				row_num = 16
				min_row = 1
				max_row = len(raw_data) + 1
				data_row = 0

				# make sure to change column for starting. Used a variable to apply to other reports
				starting_column = 'B'

				#below doesn't work...lol...number of rows 
				while min_row < max_row:
					try:
						sheet.range(starting_column+str(row_num)).value = raw_data[data_row]
					except IndexError as exception:
						"Do nothing"
					row_num += 1
					min_row += 1
					data_row += 1

		#saves and closes (add date in future)
		workbook.save(os.path.join(scorecard_finished_file_path,('scorecard_'+ '.xlsx')))
		workbook.close()


function_to_export_data_testing()
