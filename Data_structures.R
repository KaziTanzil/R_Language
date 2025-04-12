---
title: "R Data Structures"
author: "Kazi Tanzizul Haque Tanzil"
date: "`r Sys.Date()`"
output:
  html_notebook: default
  pdf_document: default
---
R provides several built-in data structures for storing and manipulating data.<br>
The main data structures in R are:<br>

Vectors<br>
Matrices<br>
Arrays<br>
Data Frames<br>
Factors<br>
Lists<br>

# Vectors
# Creating Different Types of Vectors
```{r}
# Creating Different Types of Vectors
# Numeric Vector
num_vec <- c(7,9,11,13,15,17)
print(num_vec[3])
cat("num_vec =",num_vec[2],"\n")

# Character Vector
char_vec <- c("Tanzil", "Mohim", "Gahana","Tahabi")
print(char_vec)
cat("First element is =",char_vec[1],"\n")

# Logical Vector
log_vec <- c(TRUE, FALSE, TRUE, FALSE,TRUE,TRUE)
print(log_vec)

```
```{r}
# Vector Operations
# Arithmetic Operations
vec1 <- c(2, 6, 10,28,35)
vec2 <- c(1, 3, 5,7,7)

sum_vec <- vec1 + vec2  # Element-wise addition
prod_vec <- vec1 * vec2 # Element-wise multiplication
div_vec<-vec1/vec2
sq_vec2<-vec2**2
sqrt_vec1<-sqrt(vec1)

print(sum_vec)  
print(prod_vec)  
print(div_vec)
print(sq_vec2)
print(sqrt_vec1)


```
```{r}
# Accessing Elements in a Vector
# Create a vector
num_vec <- c(10, 20, 30, 40, 50,60,70,80)

# Access elements using index (1-based index)
print(num_vec[7]) 

# Access multiple elements
print(num_vec[c(1, 5, 2)]) 

# Access elements using a condition
print(num_vec[num_vec > 25])

print(num_vec[num_vec<=30])

```
```{r}
# Modifying a Vector
# Modify an element
num_vec[6] <- 600
print(num_vec)  

# Append new elements
num_vec <- c(num_vec, 90, 100)
print(num_vec) 

# Remove last element
num_vec <- num_vec[-length(num_vec)]
print(num_vec)

# Remove element by position
num_vec <- num_vec[-6]
print(num_vec)


```
```{r}
# Vector Functions
vec <- c(30, 5, 12, 40, 18)

# Length of the vector
print(length(vec))

# Sum of all elements
print(sum(vec))  

# Mean (average) of elements
print(mean(vec)) 

# Sum of the squares of all elements
sum_of_squares <- sum(vec^2)
print(sum_of_squares)  

# Sorting a vector in ascending order
sorted_vec <- sort(vec, decreasing = FALSE)
print(sorted_vec) 

# Sorting a vector
sorted_vec <- sort(vec, decreasing = TRUE)
print(sorted_vec)  # Output: 25 20 15 10 5

```
```{r}
# Sequence and Repetition in Vectors
# Sequence from 1 to 10
seq_vec <- seq(1, 30, by = 3)  
print(seq_vec) 

# Repeat elements
rep_vec <- rep(c(1, 2, 3,4,5,6), times = 4)  # Repeat entire vector
print(rep_vec)  # Output: 1 2 3 1 2 3 1 2 3

```
# Matrices
```{r}
# Creating a 5x5 matrix (filled column-wise by default)
mat <- matrix(1:25, nrow = 5, ncol = 5)
print(mat)

mat <- matrix(20:1, ncol = 5, nrow  = 4)
print(mat)

```
```{r}
# Filling a Matrix Row-Wise
mat <- matrix(1:15, nrow = 5, byrow = TRUE)
print(mat)

```
```{r}
# Naming Rows and Columns
# Creating a matrix
mat <- matrix(1:25, nrow = 5)

# Assigning row and column names
rownames(mat) <- c("Row1", "Row2", "Row3", "Row4", "Row5")
colnames(mat) <- c("Col1", "Col2", "Col3", "Col4", "Col5")

print(mat)

```
```{r}
# Create a 4x4 matrix
mat <- matrix(1:16, nrow = 4)
print(mat)

# Access element at row 3, column 2
print(mat[3, 2])  

# Access entire row 2
print(mat[2, ]) 

# Access entire column 4
print(mat[, 4])  


```
```{r}
# Create two 4x4 matrices
mat1 <- matrix(1:16, nrow = 4)
mat2 <- matrix(17:32, nrow = 4)

print(mat1)
print(mat2)

# Matrix addition
sum_mat <- mat1 + mat2
print(sum_mat)


# Matrix multiplication (element-wise)
prod_mat <- mat1 * mat2
print(prod_mat)

# Matrix multiplication (dot product)
dot_prod_mat <- mat1 %*% mat2  # %*% for matrix multiplication
print(dot_prod_mat)

```
```{r}
# Create a 4x4 matrix
mat <- matrix(1:16, nrow = 4)

# Transpose of the matrix
t_mat <- t(mat)
print(t_mat)


# Create a 2x2 matrix for which we can compute the inverse
square_mat <- matrix(c(2, 3, 1, 4), nrow = 2)

# Inverse of the matrix (for square matrices)
inv_mat <- solve(square_mat)
print(inv_mat)

```
# Arrays
```{r}
# Creating an array with dimensions (6x6x2)
arr <- array(1:72, dim = c(6, 6, 2))

# Print the array
print(arr)


```
```{r}
# Accessing Elements in an Array
# Create a 6x6x2 array
arr <- array(1:72, dim = c(6, 6, 2))

# Access element at [2nd row, 3rd column, 1st layer]
print(arr[4, 3, 1])  

# Access entire 2nd row from Layer 1
print(arr[3, , 1])


# Access entire 3rd column from Layer 2
print(arr[, 4, 2])




```
```{r}
#Performing Operations on Arrays
# Creating two 4x4x2 arrays
arr1 <- array(1:32, dim = c(4, 4, 2))
arr2 <- array(33:64, dim = c(4, 4, 2))

# Element-wise addition
sum_arr <- arr1 + arr2
print(sum_arr)

# Element-wise multiplication
prod_arr <- arr1 * arr2
print(prod_arr)


```
```{r}
# Applying Functions to Arrays
# Creating a 6x6x2 array
arr <- array(1:72, dim = c(6, 6, 2))

# Sum of all elements in the array
print(sum(arr))

# Mean of all elements
print(mean(arr))

# Apply function to each row (margin = 1)
apply(arr, MARGIN = 1, FUN = sum)

# Apply function to each column (margin = 2)
apply(arr, MARGIN = 2, FUN = mean)



```

# Data Frames
```{r}
# Creating an employee data frame
employee_df <- data.frame(
  EmployeeID = c(101, 102, 103, 104),
  Name = c("Tanzil", "Mohim", "Gahana", "Tahabi"),
  Age = c(23, 25, 22, 24),
  Salary = c(55000, 48000, 50000, 52000),
  Department = c("HR", "Finance", "IT", "Marketing"),
  FullTime = c(TRUE, TRUE, FALSE, TRUE)
)

# Print the employee data frame
print(employee_df)


```

```{r}
# Accessing Elements in the Employee Data Frame

# Access a single column (Name column)
print(employee_df$Name) 

# Access a specific row (Row 3)
print(employee_df[3, ])  

# Print a specific element (Row 1, Column "Salary")
print(employee_df[1, "Salary"]) 

# Access multiple columns ("Name" and "Salary")
print(employee_df[, c("Name", "Salary")])  

# Access multiple rows (Rows 1 and 4)
print(employee_df[c(1,4), ])  # First four rows


```
```{r}
# Add a new column 'Increment' with string values
employee_df$Increment <- c("2%", "2", "1.5", "1.5")


print(employee_df)

```

```{r}
# Filter employees who are full-time
full_time_employees <- employee_df[employee_df$FullTime == TRUE, ]
print(full_time_employees)

# Filter employees with Salary > 50000
high_salary_employees <- employee_df[employee_df$Salary > 50000, ]
print(high_salary_employees)

```

```{r}
# Sorting by Age (Ascending)
df_sorted <- employee_df[order(employee_df$Age), ]
print(df_sorted)

# Sorting by Score (Descending)
df_sorted_desc <- employee_df[order(-employee_df$Salary), ]
print(df_sorted_desc)


```

```{r}
# Changing a value (Changing Gahana's Salary to 53000)
employee_df$Salary[employee_df$Name == "Gahana"] <- 53000
print(employee_df)

# Renaming column names
colnames(employee_df) <- c("Employee_ID", "Employee_Name", "Employee_Age", "Employee_Salary", "Employee_Department", "FullTime_Employee", "Yearly_Increament")
print(employee_df)

```

```{r}
# Remove the 'Yearly_Increament' column
employee_df$Yearly_Increament <- NULL
print(employee_df)

# Remove a row (removing row 2)
employee_df <- employee_df[-2, ]
print(employee_df)


```
```{r}
# Get summary statistics
summary(employee_df)

# Get structure of the data frame
str(employee_df)

```
# List

```{r}
# Creating a list with different data types
my_list <- list(
  Name = "Tanzil",
  Age = 25,
  Scores = c(90, 95, 88),
  Passed = TRUE
)

# Print the list
print(my_list)

```
```{r}
# Access by index
print(my_list[[1]])  

# Access by name
print(my_list$Scores)  

# Access specific elements within a list item
print(my_list$Scores[2])  # Output: 85

```
```{r}
# Change an element
my_list$Age <- 23
print(my_list$Age) 

# Add a new element
my_list$Country <- " Bangladesh"
print(my_list)

# Remove an element
my_list$Passed <- NULL
print(my_list)

```
```{r}
# Creating a list with a matrix and a data frame
my_complex_list <- list(
  Numbers = c(1, 2, 3, 4),
  Matrix = matrix(1:15, nrow = 3),
  DataFrame = data.frame(ID = c(101, 102), Name = c("Mohim", "Tahabi"))
)

# Print the list
print(my_complex_list)

# Access elements inside the matrix
print(my_complex_list$Matrix[2, 3])  # Access row 2, column 3

```
```{r}
list1 <- list(A = 1:5, B = "Hello")
list2 <- list(C = c(TRUE, FALSE), D = matrix(1:4, nrow = 2))

# Merge lists
merged_list <- c(list1, list2)
print(merged_list)

```

```{r}
# Convert list to data frame
list_to_df <- data.frame(
  Name = c("Tanzil", "Tahabi"),
  Age = c(25, 27),
  Salary = c(40000, 40000)
)
print(list_to_df)

```
