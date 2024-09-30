rm(list=ls(all=TRUE))

library(readxl)
library(dplyr)
library(tidyr)
library(reshape2)
library(rstatix)
library(ez)
library(ggplot2)
library(pacman)
library(ggpubr)
library(psych)
library(RVAideMemoire) # to perform shapiro by group
library(dunn.test)
library(ggdist)
library(gghalves)
library(esquisse)
library(zoo)
library(fpp)
library(circlize)
library(corrplot)
library(gt) # nice tables, summary statistics
library(gtExtras)# data visualisation with tables
library(ggExtra)
library(ggside)
library(gtsummary)
library(ggdist)
library(tidyverse)
library(tidyquant)
library(ggthemes)
library(hms)
library(lubridate)



#--------------------loading first and second parts of sleep detection and then merge them----------------
db1 <- read_csv("C:/Users/dc00955/OneDrive - University of Surrey/Desktop/Sara_case_report/sleep_detection_part1.csv") %>% 
  rename(datetime = ...1, state = "0")

db2 <- read_csv("C:/Users/dc00955/OneDrive - University of Surrey/Desktop/Sara_case_report/sleep_detection_part2.csv") %>% 
  rename(datetime = ...1, state = "0")

# merge:
db <- rbind(db1, db2)

head(db)
tail(db)

# fixing datetime column:
db$datetime <- as.POSIXct(db$datetime, format = "%d/%m/%Y %H:%M:%S")

# cleaning file:

# Define periods to add NA (list of lists with start and stop times)
periods <- list(
  list(start = "2022-12-28 12:00:00", stop = "2022-12-29 12:00:00"),
  list(start = "2023-03-04 22:40:00", stop = "2023-04-18 10:00:00"),
  list(start = "2023-05-14 22:30:00", stop = "2023-05-15 07:15:00"),
  list(start = "2023-05-16 09:00:00", stop = "2023-06-29 13:00:00"),
  list(start = "2023-07-31 19:15:00", stop = "2023-08-16 12:00:00"),
  list(start = "2023-08-18 10:00:00", stop = "2023-08-22 13:00:00")
)

# Loop through the periods and set 'state' to NA during the intervals
for (period in periods) {
  # Convert start and stop times to POSIXct
  start_time <- as.POSIXct(period$start)
  stop_time <- as.POSIXct(period$stop)
  
  # Add NA to 'state' column where datetime is within the interval
  db <- db %>%
    mutate(state = ifelse(datetime >= start_time & datetime <= stop_time, NA, state))
}

# Check if NAs were added
summary(db$state)

#----------------loading locations file and fixing datetime in sleep detection file according to correct timezones------------
locations <- read_excel("C:/Users/dc00955/OneDrive - University of Surrey/Desktop/Sara_case_report/locations.xlsx")

# 1) Convert 'datetime' in 'db' to POSIXct and 'date' in 'locations' to Date
db$datetime <- as.POSIXct(db$datetime, format = "%Y-%m-%d %H:%M:%S")
locations$date <- as.Date(locations$date, format = "%Y-%m-%d")

# 2) Add a 'date' column to 'db' by extracting the date part from 'datetime'
db <- db %>%
  mutate(date = as.Date(datetime))

# 3) Merge 'db' with 'locations' based on the 'date' column
db <- db %>%
  left_join(locations, by = "date")

db$location <- as.numeric(db$location)
 
# 4) Subtracting one hour from UK periods
db <- db %>%
  mutate(datetime_corrected = if_else(location == 1, 
                                      datetime - hours(1),  # Subtract 1 hour for location 1 (UK)
                                      datetime))


# 5) Calculating midpoint of sleep:

# 5.1. create grouping variable to identify distinct sleep periods (continuous "1" in the state column)
#   - NA values are handled by filling them with the last known value using `fill()` for continuity
#   - We also need to reset the grouping whenever there's an NA
db <- db %>%
  mutate(state_no_na = ifelse(is.na(state), -1, state), # Temporary column to handle NA
         sleep_period = cumsum(state_no_na != lag(state_no_na, default = state_no_na[1]))) %>%
  group_by(sleep_period)

#filter only the sleep periods (state == 1)
sleep_periods <- db %>%
  filter(state == 1)

# 5.2. Calculate the start and end time of each sleep period 
sleep_periods <- sleep_periods %>%
  group_by(sleep_period) %>%
  summarise(
    start_time = min(datetime_corrected),
    end_time = max(datetime_corrected),
    duration = as.numeric(difftime(max(datetime_corrected), min(datetime_corrected), units = "hours"))
  )

# 5.3. It is taking naps as well -->  Filter out sleep periods shorter than 3 hours
valid_sleep_periods <- sleep_periods %>%
  filter(duration >= 3)

# 5.4.  Calculate the midpoint of the valid sleep periods
valid_midpoints <- valid_sleep_periods %>%
  mutate(midpoint = start_time + (difftime(end_time, start_time) / 2))

# 6) Add "Date" column to the valid_midpoints database
valid_midpoints <- valid_midpoints %>%
  mutate(date = as.Date(start_time))

# 7) merge valid_midpoints with locations
valid_midpoints <- valid_midpoints %>%
  left_join(locations, by = "date")

# 8) take just the "time" part of the midpoint variable and convert to decimal
valid_midpoints <- valid_midpoints %>%
  mutate(midpoint_time = format(as.POSIXct(midpoint, format="%Y-%m-%d %H:%M:%S"), "%H:%M:%S"))

# Convert midpoint to decimal hours
valid_midpoints <- valid_midpoints %>%
  mutate(midpoint_h = as.numeric(substr(midpoint_time, 1, 2)) +  # Extract hours
           as.numeric(substr(midpoint_time, 4, 5)) / 60 +  # Extract minutes and convert to fraction of hour
           as.numeric(substr(midpoint_time, 7, 8)) / 3600)  # Extract seconds and convert to fraction of hour

# extracting decimal times from start and end of sleep
valid_midpoints <- valid_midpoints %>%
  mutate(sleep_start = format(as.POSIXct(start_time, format="%Y-%m-%d %H:%M:%S"), "%H:%M:%S"),
         sleep_end = format(as.POSIXct(end_time, format="%Y-%m-%d %H:%M:%S"), "%H:%M:%S"))

valid_midpoints <- valid_midpoints %>%
  mutate(sleep_start_decimal = as.numeric(substr(sleep_start, 1, 2)) +  # Extract hours
           as.numeric(substr(sleep_start, 4, 5)) / 60 +  # Extract minutes and convert to fraction of hour
           as.numeric(substr(sleep_start, 7, 8)) / 3600,
         sleep_end_decimal = as.numeric(substr(sleep_end, 1, 2)) +  # Extract hours
           as.numeric(substr(sleep_end, 4, 5)) / 60 +  # Extract minutes and convert to fraction of hour
           as.numeric(substr(sleep_end, 7, 8)) / 3600)


#------------------------------------------------plotting---------------------------------
#boxplot
ggplot(valid_midpoints, aes(x = factor(location, labels = c("Italy", "UK")), y = midpoint_h)) +
  geom_boxplot(fill = c("#508991", "chocolate")) +
  labs(title = "Midpoint of Sleep: UK vs Italy", x = "Location", y = "Midpoint (decimal hours)") +
  theme_classic()

#histogram
ggplot(valid_midpoints, aes(x = midpoint_h, fill = factor(location, labels = c("Italy", "UK")))) +
  geom_histogram(position = "identity", alpha = 0.6, bins = 20) +
  labs(title = "Distribution of Midpoint of Sleep by Location", x = "Midpoint (decimal hours)", y = "Count") +
  theme_classic() +
  scale_fill_manual(values = c("#508991", "chocolate"), name = "Location")

#density plot
ggplot(valid_midpoints, aes(x = midpoint_h, fill = factor(location, labels = c("Italy", "UK")))) +
  geom_density(alpha = 0.6) +
  labs(title = "Density Plot of Midpoint of Sleep by Location", x = "Midpoint (decimal hours)", y = "Density") +
  theme_classic() +
  scale_fill_manual(values = c("#508991", "chocolate"), name = "Location")

#time series plot
ggplot(valid_midpoints, aes(x = as.Date(date), y = midpoint_h, color = factor(location, labels = c("Italy", "UK")))) +
  geom_line() +
  labs(title = "Midpoint of Sleep Over Time", x = "Date", y = "Midpoint (decimal hours)") +
  theme_classic() +
  scale_color_manual(values = c("#508991", "chocolate"), name = "Location")

#scatter plot
ggplot(valid_midpoints, aes(x = factor(location, labels = c("Italy", "UK")), y = midpoint_h)) +
  geom_jitter(width = 0.2, aes(color = factor(location, labels = c("Italy", "UK"))), alpha = 0.7) +
  labs(title = "Scatter Plot of Midpoint of Sleep by Location", x = "Location", y = "Midpoint (decimal hours)") +
  theme_classic() +
  scale_color_manual(values = c("#508991", "chocolate"), name = "Location")

#facet histogram
ggplot(valid_midpoints, aes(x = midpoint_h)) +
  geom_histogram(bins = 20, fill = "chocolate", color = "black") +
  labs(title = "Midpoint of Sleep by Location", x = "Midpoint (decimal hours)", y = "Count") +
  facet_wrap(~ factor(location, labels = c("Italy", "UK")), scales = "free") +
  theme_grey()


