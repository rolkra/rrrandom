################################################################################
# post-surgery recovery times in days, for seven patients who were
# randomly divided into a control group of three that received standard care, and a treatment
# group of four that received a new kind of care
# use randomize, repeat and reject - method to test if difference is significant
# data source: https://escholarship.org/uc/item/6hb3k0nz
################################################################################

# load packages
library(ggplot2)
library(gridExtra)
library(dplyr)

# patients data 
nr <- 1:7
id <- 1:7
treatment <- c(0, 0, 0, 1, 1, 1, 1)
recover <- c(22, 33, 40, 19, 22, 25, 26)
data <- data.frame(nr, id, treatment, recover)
str(data)

# makes treatment a difference?
treat_mean <- data %>% 
   group_by(treatment) %>% 
   summarize(recover_mean = mean(recover), n = n())
treat_mean

diff <- treat_mean[[1,2]] - treat_mean[[2,2]]
diff

# plot 
data %>% 
   ggplot(aes(x = treatment, y = recover, fill = as.factor(treatment))) + 
   geom_dotplot(binaxis='y', stackdir='center') +
   ggtitle("recover time by treatment")

# detailed plot
ggplot(treat_mean, aes(treatment, recover_mean, fill = as.factor(treatment))) +
   geom_col(alpha = 0.5) +
   ylab("recover time") +
   labs(fill = "treatment") +
   ggtitle(paste("recover time by treatment: difference = ", round(diff,1),"days")) +
   geom_point(data = data, aes(x = treatment, y = recover, fill = as.factor(treatment)), 
              shape = 21, size = 5) +
   geom_hline(yintercept = treat_mean[[1,2]], alpha = 0.5, linetype = "dotted") +
   geom_hline(yintercept = treat_mean[[2,2]], linetype = "dotted", alpha = 0.5)

################################################################################
# randomise and repeat 
################################################################################

n <- 1000

result <- vector("numeric")
p_cum <- vector("numeric")
days_min <- diff

set.seed(111)
for (i in 1:n) {
   
   # select 3 random patients for the control group 
   treatment_random <- c(1,1,1,1,1,1,1)
   cg_random <- sample(nr, 3, replace = FALSE)
   treatment_random[cg_random] <- 0
   
   # other strategies to generate random control group
   #treatment_random <- sample(c(0,1), length(treatment), replace = TRUE)
   #treatment_random <- sample(treatment, length(treatment), replace = FALSE)
   
   data_new <- cbind(data, treatment_random)
   
   # calculate difference between treatment and control group
   treat_mean <- data_new %>% 
      group_by(treatment_random) %>% 
      summarize(treat_mean = mean(recover), n = n())
   
   diff <- treat_mean[[1,2]] - treat_mean[[2,2]]
   
   result <- c(result, diff)  
   p_cum <- c(p_cum, sum(result >= days_min) / length(result))
   
} # for

################################################################################
# reject? 
################################################################################

# probability that the result is just random
p_random <- sum(result >= 8.66) / length(result)

# result & visualisation 
data_random <- data.frame(step = seq_along(result), result, p_cum)

p1 <- data_random %>% 
   ggplot(aes(result)) + 
   geom_density(fill = "darkgrey", alpha = 0.5) +
   geom_vline(xintercept = 8.66, color = "red", alpha = 0.5) +
   ggtitle(paste0("random control group: step = ", n, ", p(result >= 8.7) = ", p_random))

p2 <- data_random %>% 
   ggplot(aes(step, p_cum)) +
   geom_line() +
   geom_hline(yintercept = p_random, color = "red") +
   ylab("aproximation p(result >= 8.7)")

grid.arrange(p1, p2, nrow = 2)

