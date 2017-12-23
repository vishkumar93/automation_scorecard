import xlwings as xw
import csv
import os


#Below script reads csv file into a raw data list
def read_csv_file(file_name):
	raw_data = []
	with open(file_name,'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:
			raw_data.append(row)
	return raw_data,file_name

#assign existing tab to variable
def function_to_export_data(file_name):
	# find existing workbook
	#scorecard_template_path = os.path.expanduser(r"~\automation_scorecard\excel_files\scorecard_template.xlsx")
	raw_data, file_name = read_csv_file(file_name)
	workbook = xw.Book(scorecard_template_path)

	if 'campaign' in file_name:
		sheet = workbook.sheets['Campaign']
	elif 'partner' in file_name:
		sheet = workbook.sheets['Partner']
	elif 'camp' in file_name:
		sheet = workbook.sheets['Campaign & Partner']
	elif 'team' in file_name:
		sheet = workbook.sheets['Team']

	# skip the header row and starts at the 16th row since that is where the scorecard reports begin
	# max_row is used for a while loop, which will terminate once all the rows in our csv are read
	row_num = 16
	max_row = len(raw_data) + 1 

	# while number of rows is less than 45 since there are 44 columns, continue writing each row
	# make sure to change column for starting. Used a variable to apply to other reports
	starting_column = 'B'

	while row_num < max_row:
		sheet.range(starting_column+str(row_num)).value = raw_data[0]
		row_num += 1

	#saves and closes using date from get_date() function
	workbook.save('Scorecard - New.xlsx')
	workbook.close()
	#closes without savings
	#workbook.close()


#function_to_export_data('AKQA_Clorox_partner.csv')

def get_report_date():
	date = raw_input("Please enter the date in YYYY-MM format: ")
	validate_date(date)


#this function validates the number of characters in the date to ensure it is properly formatted
def validate_date(date):
	try:
		if len(date)==7:
			return True

		else: return False

	except ValueError:
		return False

raw_data_path = os.path.expanduser(r"~\automation_scorecard\excel_files")
file_input = raw_input('Enter File: ')
raw_file_path = os.path.join(raw_data_path,file_input)
function_to_export_data(raw_file_path)