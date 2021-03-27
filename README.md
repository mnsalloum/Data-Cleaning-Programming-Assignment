# Data Cleaning Programming Assignment for Coursera
Files: 
Codebook.md
  lists all the variables in the UCI_HAR_Run_Analysis script and explains the thought process behind each line of code

UCI_HAR_Run_Analysis.R
 1. Downloads and unzips the file UCI HAR dataset
 2. Reads the datasets and merges them.
 3. Changes the names of the columns of the datasets.
 4. extracts the measurements on mean and standard deviation.
 5. changes the activies names according to the activity_labels.txt
 6. labels columns with descriptive, less abbreviated names.
 7. uses group_by and summerize to find the average of each variable for each activity and each subject.
 8. exports the cleaned data to a txt file.
