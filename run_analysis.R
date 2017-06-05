library(dplyr)

## Read train data
x_train<-read.fwf(file="train/x_train.txt", widths=c(rep(16,561)))
y_train<-read.csv2("train/y_train.txt", header=FALSE)
subject_train<-read.csv2("train/subject_train.txt", header=FALSE)

## Read test data
x_test<-read.fwf(file="test/x_test.txt", widths=c(rep(16,561)))
y_test<-read.csv2("test/y_test.txt", header=FALSE)
subject_test<-read.csv2("test/subject_test.txt", header=FALSE)

##read the features data
features<-read.table("features.txt", sep=" ")

##create a logical vector with measures regarding mean and std
pos<-features[as.numeric(regexpr('-mean',features[,2]))!=-1|as.numeric(regexpr('-std',features[,2]))!=-1,1]

##extra only measurements on mean and standard deviation from the features data
selected_features<-features[pos,]

##put the measurement names in a vector
messnames<-as.character(selected_features[,2])

##extract only measurements on mean and standard deviation from train and test data
subset_xtrain<-x_train[,pos]
subset_xtest<-x_test[,pos]

##join the subject-info, training labels and training data
train<-cbind(subject_train, y_train, subset_xtrain)

##join the subject-info, test labels and test data
test<-cbind(subject_test, y_test, subset_xtest)

##join the set with training data and test data
total_df<-rbind(train,test)

##rename the columns
names(total_df)<-c("subject_number","activity_number",messnames)

##read activity labels
activity_labels<-read.fwf(file="activity_labels.txt", widths=c(1, 1, 20), col.names=c("activity_number", "space", "activity_name"))

##drop the space column
activity_labels<-activity_labels[,c(1,3)]

##join on activity_number to get the activity_labels
total_df<-inner_join(total_df, activity_labels)

##reorder the columns and drop the activity_number
##this is the final data set with descriptive variable names and activity names
##instead of activity numbers
total_df<-total_df[,c(1,82,3:81)]

##create a data set with the mean on all measurements per
##subject_number and activity_name
by_subact<-group_by(total_df, subject_number, activity_name)
sum_df<-summarise_all(by_subact, mean)
