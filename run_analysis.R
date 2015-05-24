# load useful libraries
library(dplyr)
library(Hmisc)

# load the names of the features
features <- read.table("features.txt", header=FALSE, col.names=c("ID","name"), stringsAsFactors=FALSE)
# but we only need the mean and standard deviation of each measurement, so filter the rows
# first, we get the mean measurements and store in a new data frame
valid_features <- subset(features, grepl("mean()", features$name, fixed=TRUE))
# and also the standard deviation measurements. We add this data frame to the last data frame
valid_features <- rbind(valid_features, subset(features, grepl("std()", features$name, fixed=TRUE)))
# set more appropiate variable names (remove the brackets and the minus signs)
valid_features$name <- gsub("\\(\\)", "", valid_features$name)
valid_features$name <- gsub("\\-", ".", valid_features$name)

# load the names of the activities
activities <- read.table("activity_labels.txt", header=FALSE, col.names=c("ID","activity_name"))


# read the test files and store the data 
subject_test <- read.table("test/subject_test.txt", header=FALSE, col.names="subject_ID")
x_test <- read.table("test/X_test.txt", header=FALSE, col.names=features$name)
# get only the features requested
x_test <- x_test[, valid_features$ID]
y_test <- read.table("test/y_test.txt", header=FALSE, col.names="activity_ID")
# get the name of the activity instead of its ID
y_test <- merge(y_test, activities, by.x="activity_ID", by.y="ID", all.x=TRUE)
y_test <- subset(y_test, select="activity_name")
# combine the test data frames in only one
all.data.test <- cbind(subject_test, y_test, x_test )
# we don't need the temporal dataframes, so remove it from the environment
rm(subject_test)
rm(x_test)
rm(y_test)

# do the same actions, but with the train data
subject_train <- read.table("train/subject_train.txt", header=FALSE, col.names="subject_ID")
x_train <- read.table("train/X_train.txt", header=FALSE, col.names=features$name)
# get only the features requested
x_train <- x_train[, valid_features$ID]
y_train <- read.table("train/y_train.txt", header=FALSE, col.names="activity_ID")
# get the name of the activity instead of its ID
y_train <- merge(y_train, activities, by.x="activity_ID", by.y="ID", all.x=TRUE)
y_train <- subset(y_train, select="activity_name")
# combine the train data frames in only one
all.data.train <- cbind(subject_train, y_train, x_train )

# clean the environment
rm(subject_train)
rm(x_train)
rm(y_train)

# and finally, combine the two data sets in only one
all.data <- rbind(all.data.test, all.data.train)
# and remove them from the environment
rm(all.data.test)
rm(all.data.train)

# now, in order to get the step no 5, first we have to group the data by subject and activity
groups_by_subject_and_activity <- group_by(all.data, subject_ID, activity_name)
# ...and store the data in a data frame
group.data <- summarise_each(groups_by_subject_and_activity, funs(mean))

# THIS STEP IS ONLY NECESSARY TO COMPLETE THE EXERCISE 1 OF THE COURSE PROJECT
# write.table(group.data, file="group.data.txt", row.name=FALSE)

# output the data
View(group.data)


