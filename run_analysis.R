##This script loads, cleans and merges the UCI HAR Dataset
##from a folder named "UCI HAR Dataset" as seen at
##https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

library(dplyr)

## loads the training dataset and adds column names

X_train <- read.table("UCI HAR Dataset\\train\\X_train.txt", 
                      comment.char = "", colClasses = "numeric")
features <- read.table("UCI HAR Dataset\\features.txt")
names(X_train) <- features[,2]

## loads and combines the subject and activity id numbers to the training dataset

y_train <- read.table("UCI HAR Dataset\\train\\y_train.txt", 
                      col.names="activity_id")
subject_train <- read.table("UCI HAR Dataset\\train\\subject_train.txt", 
                            col.names="subject_id")
training_data <- cbind(subject_train,y_train,X_train)

##same process for the test dataset

X_test <- read.table("UCI HAR Dataset\\test\\X_test.txt", 
                     comment.char = "", colClasses = "numeric")
names(X_test) <- features[,2]

y_test <- read.table("UCI HAR Dataset\\test\\y_test.txt", 
                     col.names="activity_id")
subject_test <- read.table("UCI HAR Dataset\\test\\subject_test.txt",
                           col.names="subject_id")
test_data <- cbind(subject_test,y_test,X_test)

##Combines the two datasets together,
##And merges the activity names to the id numbers

full_data <- rbind(training_data,test_data)
activity_labels <- read.table("UCI HAR Dataset\\activity_labels.txt", 
                              col.names= c("activity_id", "activity_name"))
full_data <- merge(activity_labels, full_data)

##Creates a dataset of only the mean and standard deviation measurments
##And replaces the default column names to make them more descriptive

mean_std <- select(full_data, 
                   activity_name, subject_id, 
                   contains("mean()"), contains("std()"))

names(mean_std) <- gsub("^t","Time-", names(mean_std))
names(mean_std) <- gsub("^f","Frequency-", names(mean_std))
names(mean_std) <- gsub("Acc","-acceleration", names(mean_std))
names(mean_std) <- gsub("Gyro","-gyroscope", names(mean_std))
names(mean_std) <- gsub("Mag","-magnitude", names(mean_std))
names(mean_std) <- gsub("std","standard deviation", names(mean_std))

##Finally creates a second tidy dataset with the avrage measurments
##For each activity and each subject, and writes it to a file

grouped_avarage <- mean_std %>% 
                        group_by(activity_name, subject_id) %>% 
                              summarise_each(funs(mean))

write.table(grouped_avarage, file="grouped_avarage.txt", row.name=FALSE)
