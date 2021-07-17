#Set your own working directory
setwd("C:/Users/diego/Documents/R/Projects/GitHub_Projects/Optimization/1D Cutting Stock")

#Import required packages
library(dplyr)
library(ROI)
library(ROI.plugin.symphony)
library(ompr)
library(ompr.roi)


#Define input Data
A <- matrix(c(1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0,
              1, 0, 2, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0,
              0, 2, 0, 1, 0, 0, 1, 0, 1, 2, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
              0, 1, 0, 0, 2, 0, 0, 2, 2, 0, 1, 1, 1, 3, 0, 0, 0, 2, 0, 1,
              1, 0, 1, 1, 0, 4, 1, 0, 0, 1, 1, 1, 1, 0, 2, 2, 2, 1, 0, 2), nrow=5, byrow = TRUE)

d <- c(50, 30, 40,42, 20)

#Build model
Model <- MIPModel() %>%
         add_variable(x[j], j = 1:ncol(A), type = "integer") %>%   #define variables
         set_bounds(x[j],j = 1:ncol(A), lb = 0) %>%                #define variables' lower bound
         set_objective(sum_expr(x[j], j = 1:ncol(A)), "min") %>%   #define objective function
         add_constraint(sum_expr(A[i, j]*x[j], j = 1:ncol(A)) >= d[i], i = 1:nrow(A)) %>% #define constraints
         solve_model(with_ROI(solver = "symphony",verbosity = 1))


#Model Summary

print(paste("Objective value: ", Model$objective_value))
for (j in 1:ncol(A)) {
  if (Model$solution[j] > 0) {
    print(paste("x[",j,"] = ", Model$solution[j]))
  }
}
