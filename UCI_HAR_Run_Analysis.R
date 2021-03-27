# This code will download and clean the UCI HAR Dataset and provide a tidy 
# dataset with the average of certain variables of interest.

# We will start by loading a few packages that we will need to read
# and clean the data
if(!"dplyr" %in% installed.packages()[,1]) {install.packages(dplyr)}
library(dplyr)
if(!"stringr" %in% installed.packages()[,1]) {install.packages(stringr)}
library(stringr)

# Now we will download the datasets
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"  
download.file(URL, destfile = "UCI_HAR_Dataset.zip")
unzip("UCI_HAR_Dataset.zip")

# The downloaded file contains multiple small datasets. Our goal is to merge these
# small datasets into one big dataset so that we can clean the whole dataset 
# one time instead of having to do the cleaning on each and every one of them
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt",header=F)
x_test <- bind_cols(y_test,subject_test,x_test)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header=F)
x_train <- bind_cols(y_train,subject_train,x_train)

# So we just loaded 6 tables into R and merged the 3 tables about the test data 
# into one table and the 3 tables about the train data into one table. Now we
# need to name the columns of these datasets. Their column names are available 
# in other datasets, namely the features and the activity_labels dataset.
column_names <- read.csv("UCI HAR Dataset/features.txt",sep = " ",header = F)[,2]
column_names <- make.names(column_names, unique = T)
column_names <- c("activity","subject", column_names)
names(x_test) <- column_names
names(x_train) <- column_names

# Our test and train datasets are ready to be merged. But before we merge them,
# let's create a new variable called "group" to keep track of which subjects belong
# to the train group and which ones belong to the test group.
x_test <- mutate(x_test,group="test", .after = activity)
x_train <- mutate(x_train,group="train", .after = activity)

# Q1. Merge the training and the test sets to create one data set.
merged_dataset <- bind_rows(x_train,x_test)

# Q2. Extract only the measurements on the mean and standard deviation for each
# measurement. Will filter out the mean and std columns and then bind them to 
# the activity, group, and subject columns to make our filtered dataset. 
filtered_columns <- grep("mean|std",column_names,value = T) %>%
                     c("activity","group","subject")
filtered_dataset <- select(merged_dataset, all_of(filtered_columns))

# Q3. Use descriptive activity names to name the activities in the data set.
# We need to load the activity_labels dataset into R and then add a column in our 
# filtered dataset and cast the values of the activity_labels dataset into our 
# filtered dataset. 
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]
activity_labeled_dataset <- mutate(filtered_dataset,
                            activity_type=activity_labels[filtered_dataset$activity])

# Q4. Appropriately label the data set with descriptive variable names. From the
# features_info file, t = time, acc = accelerometer, gyro = gyroscope
# mag = magnitude, f = frequency. We will use these descriptive variable names 
# instead of the current names. 
appropriately_labeled_dataset <- activity_labeled_dataset
names(appropriately_labeled_dataset) <-sub("^t", "time_",
                                      names(appropriately_labeled_dataset))
names(appropriately_labeled_dataset) <-  sub(".Acc", "_acceleration ",
                                              names(appropriately_labeled_dataset)) 
names(appropriately_labeled_dataset) <-  sub(".Gyro", "_gyroscope ",
                                              names(appropriately_labeled_dataset))
names(appropriately_labeled_dataset) <-  sub(".Bod", "_body_",
                                             names(appropriately_labeled_dataset))
names(appropriately_labeled_dataset) <-  sub(".Grav", "_gravity_",
                                             names(appropriately_labeled_dataset))
names(appropriately_labeled_dataset) <-  sub("^f", "frequency_", 
                                              names(appropriately_labeled_dataset))
names(appropriately_labeled_dataset) <-  sub("Mag", " magnitude ",
                                              names(appropriately_labeled_dataset))

# Q5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject. We will
# need to create subgroups in our dataset and then apply the mean function to 
# these subgroups independently. 
tidy_dataset <- appropriately_labeled_dataset %>% 
  group_by(subject, activity)%>%
  summarise(across(.cols = everything(), mean)) 
# Finally, I will create a text file of the final tidy dataset to upload it to 
# my Github account
write.table(tidy_dataset, "tidy_dataset.txt")