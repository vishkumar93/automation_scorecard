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


#in this second test we want the function to loop through 
#assign existing tab to variable
def function_to_export_data_testing(raw_data_path,d):
	#function constants
	scorecard_template_path = os.path.expanduser(r"~\automation_scorecard\excel_files\scorecard_template.xlsx")
	scorecard_finished_file_path = os.path.expanduser(r"~\automation_scorecard\excel_files")

	# use directory for looping
	for directory in d:
		raw_data_files_path = os.path.join(raw_data_path,directory)
	for (dirpath, dirnames, filenames) in os.walk(raw_data_files_path):
	    files.extend(filenames)
	    break
	    
	for file_name in files:
		raw_file_path = os.path.join(raw_data_files_path,file_name)
		function_to_export_data(raw_file_path)

	
	raw_data, csv_file_name = read_csv_file(file_name)
	workbook = xw.Book(scorecard_template_path)
	#cleaned_file_name = clean_file_name(file_name)

	if 'campaign' in file_name:
		sheet = workbook.sheets['Campaign']
	elif 'partner' in file_name:
		sheet = workbook.sheets['Partner']
	elif 'cp' in file_name:
		sheet = workbook.sheets['Campaign & Partner']
	elif 'team' in file_name:
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




#Code that functions are used in

#file path for raw data which is used to access each report folder with it's distinct raw data files
raw_data_path = os.path.expanduser(r"~\automation_scorecard\raw_data")


directory_list = []
raw_data_files_list = []

#fetch all folders in raw_data_path 
for (dirpath, dirnames, filenames) in os.walk(raw_data_path):
    directory_list.extend(dirnames)
   
#fetch all files within the folders in raw_data_path

for directory in directory_list:
	raw_data_files_path = os.path.join(raw_data_path,directory)

	for (dirpath, dirnames, filenames) in os.walk(raw_data_files_path):
	    raw_data_files_list.extend(filenames)
	    print raw_data_files_list