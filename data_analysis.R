## Setting up of RStudio environment
library(tidyverse)
bikeshare <- read_csv("C:/Users/user/Desktop/Data learning/_Google Data Analytics Course/Course 8 - Capstone project/Data/bikeshare_data.csv")

# Preview of data frame's contents
glimpse(bikeshare)



## Proportion of customer types
customer_type_count <- bikeshare %>%
  group_by(customer_type) %>%
  summarize(ride_count=n()) %>%
  mutate(proportion=ride_count/sum(ride_count))

view(customer_type_count)

customer_type_count_bar <- customer_type_count %>%
  ggplot() + geom_col() + aes(x=customer_type, y=proportion*100, fill=customer_type) +
  geom_text(aes(label=ride_count), vjust=1.5) + 
  scale_x_discrete(labels=c("Casual rider", "Annual member")) +
  theme(legend.position="none") +
  labs(title="Number of rides by Customer type", x="Customer type", y="Percentage of rides (%)")

customer_type_count_bar



## Distribution of trips made each month, by customer type
# Additional column to indicate month with highest ride count also created
trip_count_month <- bikeshare %>%
  group_by(month,customer_type) %>%
  summarize(ride_count=n()) %>%
  ungroup() %>%
  group_by(customer_type) %>%
  mutate(proportion = ride_count*100/sum(ride_count),
         top_month = ifelse(ride_count == max(ride_count), TRUE, FALSE),
         month_letter = month.abb[month])

view(trip_count_month)

# Grouped bar plot showing number of rides over month
trip_count_month_chart <- trip_count_month %>%
  ggplot(aes(x=factor(month), y=ride_count, fill=customer_type, color=top_month)) +
  geom_col(position="dodge", linewidth=0.6) +
  geom_text(data = filter(trip_count_month, top_month == TRUE),
            aes(label = month_letter, vjust = -0.5)) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_discrete(labels = c("Casual rider", "Annual member")) +
  scale_color_manual(values = c("TRUE"="gray30", "FALSE"="transparent")) + 
  guides(color = "none") +
  labs(title = "Number of rides over each month",
       x="Month", y="Number of rides", fill="Customer type")

trip_count_month_chart

# Plots of percentage of rides over month within each customer type
trip_count_month_subgroup <- trip_count_month %>%
  ggplot(aes(x=factor(month), y=proportion, fill=customer_type, color=top_month)) +
  geom_col(position="dodge", linewidth=0.6) + 
  geom_text(data = filter(trip_count_month, top_month == TRUE),
            aes(label = month_letter, vjust = -0.5)) +
  facet_wrap(~customer_type, labeller = as_labeller(c("casual"="Casual rider", "member"="Annual member"))) + 
  scale_color_manual(values = c("TRUE"="gray30", "FALSE"="transparent")) + 
  theme(legend.position="none") +
  labs(title = "Percentage of rides over each month",
       x="Month", y="Percentage of rides (%) within group")
  
trip_count_month_subgroup



## Rides made each day of the week, by customer type
trip_count_dow <- bikeshare %>%
  group_by(day_of_week, customer_type) %>%
  summarize(ride_count=n()) %>%
  ungroup() %>%
  group_by(customer_type) %>%
  mutate(proportion=ride_count*100/sum(ride_count),
         day_of_week_letter = c('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[day_of_week+1])

view(trip_count_dow)

# Proportion of rides on weekend vs weekday
trip_count_dow %>%
  filter(day_of_week %in% c(6,0)) %>% summarize(sum(proportion))
trip_count_dow %>%
  filter(day_of_week %in% c(1,2,3,4,5)) %>% summarize(sum(proportion))

# Grouped bar plot showing number of rides over day of the week
trip_count_dow_chart <- trip_count_dow %>%
  ggplot(aes(x=fct_reorder(day_of_week_letter, day_of_week), y=ride_count, fill=customer_type)) +
  geom_col(position="dodge") +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_discrete(labels=c("Casual rider", "Annual member")) +
  labs(title="Number of rides over each day of the week",
       x="Day of the week", y="Number of rides", fill="Customer type")

trip_count_dow_chart



## Distribution of start time of rides, by customer type
# We convert time_of_day into POSIXct format, so that we can better format it within our histogram plot, using scale_x_datetime
# To calculate proportion, we use computed variables generated by ggplot() such as "..count..", "..panel..". Although modifying the "bikeshare" data frame to group entries by start time of rides per hour is easier, the immense size of our data frame would cause the process to take up too much memory.

bikeshare <- mutate(bikeshare, f_time_of_day = as.POSIXct(time_of_day,format = "%H:%M:%S", tz = "UTC"))

trip_count_time_chart <- bikeshare %>%
  ggplot(aes(x=f_time_of_day, fill=customer_type,
             y = ..count..*100/tapply(..count.., ..PANEL.., sum)[..PANEL..])) +
  geom_histogram(bins=24) +
  facet_wrap(~customer_type, labeller = as_labeller(c("casual"="Casual rider", "member"="Annual member"))) +
  scale_y_continuous(labels = scales::comma) + 
  scale_x_datetime(date_labels="%H:%M") + 
  theme(legend.position="none", panel.spacing = unit(0.5,"cm")) + 
  labs(title="Percentage of rides over start time of ride",
       x="Time of the day (h)", y="Percentage of rides (%) within group")

trip_count_time_chart

# We further investigate the start time of rides, over weekdays or weekends.
trip_count_time_chart_dow <- bikeshare %>%
  ggplot(aes(x=f_time_of_day, fill=customer_type,
             y=..count..*100/tapply(..count.., ..PANEL.., sum)[..PANEL..])) +
  geom_histogram(bins=24) +
  facet_wrap(~customer_type + case_when(
    day_of_week %in% c(1,2,3,4,5) ~ "Weekdays",
    day_of_week %in% c(6,0) ~ "Weekends"
  ), labeller = labeller(customer_type = c("casual"="Casual rider", "member"="Annual member"))) +
  scale_y_continuous(labels = scales::comma) + 
  scale_x_datetime(date_labels="%H:%M") + 
  theme(legend.position="none", panel.spacing = unit(0.5,"cm")) + 
  labs(title="Percentage of rides over start time of ride",
       x="Time of the day (h)", y="Percentage of rides (%) within group")

trip_count_time_chart_dow


## Distribution of duration of each trip, by customer type
# As with time_of_day, we also convert ride_length into POSIXct format, then calculate proportion using ggplot() computed variables in a similar process.
# Rides above 3 hours only make up a tiny proportion of overall rides, and are hence removed to make the chart easier to read.

bikeshare <- mutate(bikeshare, f_ride_length = as.POSIXct(ride_length,format = "%H:%M:%S", tz = "UTC"))

trip_count_length_chart <- bikeshare %>%
  filter(ride_length < as.difftime(3, units = "hours")) %>%
  ggplot(aes(x=f_ride_length, fill=customer_type,
             y=..count..*100/tapply(..count.., ..PANEL.., sum)[..PANEL..])) +
  geom_histogram(bins=12) +
  facet_wrap(~customer_type, labeller = as_labeller(c("casual"="Casual rider", "member"="Annual member"))) +
  scale_y_continuous(labels = scales::comma) + 
  scale_x_datetime(date_labels="%H:%M") + 
  theme(legend.position="none", panel.spacing = unit(0.5,"cm")) + 
  labs(title="Percentage of rides over ride duration",
       subtitle="Up to 3 hours",
       x="Duration of ride (h)", y="Percentage of rides (%) within group")

trip_count_length_chart


# We further investigate breakdown of ride duration over day of week, for casual riders.
# Durations under 30 minutes have been omitted.
trip_count_length_chart_casual <- bikeshare %>%
  filter(customer_type == "casual", ride_length < as.difftime(3, units = "hours")) %>%
  ggplot(aes(x=f_ride_length, fill=customer_type,
             y=..count..*100/tapply(..count.., ..PANEL.., sum)[..PANEL..])) +
  geom_histogram(bins=10) +
  facet_wrap(~case_when(
    day_of_week %in% c(1,2,3,4,5) ~ "Weekdays",
    day_of_week %in% c(6,0) ~ "Weekends"
  )) +
  scale_y_continuous(labels = scales::comma) + 
  scale_x_datetime(limits=as.POSIXct(c("1970-01-01 00:30:00", "1970-01-01 03:00:00"), tz="UTC"), date_labels="%H:%M") + 
  theme(legend.position="none", panel.spacing = unit(0.5,"cm")) + 
  labs(title="Percentage of rides over duration of ride (casual riders)",
       subtitle="Between 30 minutes to 3 hours",
       x="Duration of ride (h)", y="Percentage of rides (%) within group")

trip_count_length_chart_casual



## Most common stations rides started at (top 10)
common_stations_start <- bikeshare %>%
  filter(customer_type == "casual") %>%
  group_by(start_station_name) %>%
  summarize(start_count = n()) %>%
  arrange(-start_count) %>% 
  top_n(10) %>%
  mutate(ranking = seq.int(nrow(common_stations_start)))

view(common_stations_start)

common_stations_start_chart <- common_stations_start %>%
  ggplot(aes(x=start_count, y=fct_reorder(start_station_name, -ranking), fill=start_count)) +
  geom_col() +
  theme(legend.position="none", axis.text.y=element_text(angle=15, size=8),
        axis.title.y=element_blank()) +
  scale_fill_viridis_c() + 
  labs(title="Top 10 bike stations by number of rides started",
       subtitle="For casual riders", x="Number of rides")

common_stations_start_chart


## Most common stations rides ended at (top 10)
common_stations_end <- bikeshare %>%
  filter(customer_type == "casual") %>%
  group_by(end_station_name) %>%
  summarize(end_count = n()) %>%
  arrange(-end_count) %>% 
  top_n(10) %>%
  mutate(ranking = seq.int(nrow(common_stations_end)))

view(common_stations_end)

common_stations_end_chart <- common_stations_end %>%
  ggplot(aes(x=end_count, y=fct_reorder(end_station_name, -ranking), fill=end_count)) +
  geom_col() +
  theme(legend.position="none", axis.text.y=element_text(angle=15, size=8),
        axis.title.y=element_blank()) +
  scale_fill_viridis_c() + 
  labs(title="Top 10 bike stations by number of rides ended",
       subtitle="For casual riders", x="Number of rides")

common_stations_end_chart
