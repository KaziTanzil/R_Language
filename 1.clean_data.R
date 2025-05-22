#
#          Author: Kazi Tanzil
#         Title: Clean Currency Data in R
#  Data File Used: 1.Data_File.csv
#
salesData <- read.csv(file = "1.Data_File.csv", header = TRUE, sep = ",")
print(salesData)
#
# Attempt to calculate mean of Revenue variable
mean(salesData$Revenue)    # Error message
#
# Replace comma with blank
salesData$Revenue <- gsub(",","", salesData$Revenue)    # Replace "," in "Revenue"
print(salesData)
#
# Replace Currency sign with blank
salesData$Revenue <- gsub("\\$","", salesData$Revenue)  # Replace "$" (special character - use \\)
print(salesData)   # $ sign removed
#
# Attempt to calculate mean of Revenue variable
mean(salesData$Revenue)    # Error message
#
# Revenue variable is character type - need to coerce to numeric
salesData$Revenue <- as.numeric(salesData$Revenue)
#
# Calculate mean of Revenue variable 
mean(salesData$Revenue)  # Mean = 31088.4
#
