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
library(sugrrants)

install.packages("sugrrants")

# reading csv and specifying types of date and time columns
#define directory "C:/Users/gg00642/OneDrive - University of Surrey/Desktop/Actigraphy Sara"
setwd("C:\\Users\\gg00642\\OneDrive - University of Surrey\\Desktop\\Actigraphy Sara")

db <- read_excel("\\activity_1part_Sara_report.xlsx", sheet = "Sheet1", col_types = cols(date = col_date("%Y/%m/%d"), col_time("%H/%M/%S")))


hourly_peds %>%
  filter(Date < as.Date("2022-09-22")& Date <= as.Date("2022-12-22")) %>%  # filtering 3 months
  ggplot(aes(x = Time, y = Hourly_Counts, colour = Sensor_Name)) +
  geom_line() +
  facet_calendar(~ Date) + # a variable contains dates
  theme_bw() +
  theme(legend.position = "bottom")

p <- hourly_peds %>%
  filter(Date < as.Date("2022-09-22")& Date <= as.Date("2022-12-22")) %>%
  mutate(Weekend = if_else(Day %in% c("Saturday", "Sunday"), "Weekend", "Weekday")) %>%
  frame_calendar(x = Time, y = Hourly_Counts, date = Date) %>% 
  ggplot(aes(x = .Time, y = .Hourly_Counts, group = Date, colour = Weekend)) +
  geom_line() +
  theme(legend.position = "bottom")
prettify(p)

p
