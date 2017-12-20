# automation_scorecard

Scorecard Automation project repo. This contains the SQL files, excel files, report configurations, and python scripts associated with this project.

# What does this project  do?

As of now these tools accomplish two things: updating SQL templates with team IDs, and splitting a large CSV file into separate csvs that are report-specific. This saves time when it comes to running multiple queries and dealing with large csv files. We used to run almost 100 queries but now we are down to 5 queries (10 for quarterly reports).

The two pieces of code that need to be run are

1) sql_template_updater.py - this takes ALL of the team ids from each report configuration and updates the master sql files. Saved raw extracts go in excel_files. This utilizes another module that I created called get_team_ids.py.

2) report_auto2.py - this file uses split_master_3.py to allow the user to select a file from the "excel_files" folder, and split it according to all the reports in the "config" folder.

Note - the Raw Data will constantly be changing. Technically there is no need to store CSV's in Git. I might change it so that raw data is generated on a local file but till it's not urgent.
