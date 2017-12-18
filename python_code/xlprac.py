import xlsxwriter
import csv

#Below script reads csv file into a raw data list
raw_data = []
file_name = "AKQA_Clorox_c.csv"	
with open(file_name,'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=',')
	for row in reader:
		raw_data.append(row)


#opens workbook and creates a raw data tab
workbook = xlsxwriter.Workbook('xlsxPract.xlsx')
worksheet = workbook.add_worksheet('Raw Data')

#script creates a table
worksheet.add_table('A1:AR10000')

# skip the header row
row_num = 2
max_row = len(raw_data) + 1

# while number of rows is less than 45 since there are 44 columns, continue writing each row
while row_num < max_row:
	worksheet.write_row('A'+(str(row_num)),raw_data[0])
	row_num += 1
	

workbook.close()