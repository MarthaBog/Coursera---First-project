library(tidyverse)
library(ggplot2)
library(scales)


# cleaning and sorting and combining tables
## bind_rows is used to combine rows of two data frames.
two_tables <- bind_rows(Divvy_Trips_2019_Q1_Divvy_Trips_2019_Q1,Divvy_Trips_2020_Q1_Divvy_Trips_2020_Q1 )

## one table has ride_id as a text, another as number. I will convert it to samte type.
Trips_2019 <- Divvy_Trips_2019_Q1_Divvy_Trips_2019_Q1 %>%
  mutate(ride_id = as.character(ride_id))
 
Trips_2020 <- Divvy_Trips_2020_Q1_Divvy_Trips_2020_Q1 %>%
  mutate(ride_id = as.character(ride_id))
# Combining rows
two_tables <- bind_rows(Trips_2019,Trips_2020)

# Clean and standartize data
# Convert to lowercase and group user types
two_tables <- two_tables %>%
  mutate(usertype = case_when(
    tolower(usertype) %in% c("customer", "casual") ~ "casual",
    tolower(usertype) %in% c("subscriber", "member") ~ "member",
    TRUE ~ usertype
  ))

# Extracting date (month) and group by usertype
two_tables <- two_tables %>%
    mutate(started_at = as.POSIXct(started_at), #Convert to datetime
           month = lubridate:floor_date(started_at, unit = "month")) %>%
  group_by(month, usertype) %>%
  summarise(trip_count = n(), .groups = "drop")

# R says that started_at has string format, i can check it through:
head(two_tables$started_at)

# Fixing the problem by using format
two_tables <- two_tables %>%
  mutate(started_at = as.POSIXct(started_at, format = "%Y-%m-%d %H:%M:%S")) %>%
  mutate(month = lubridate::floor_date(started_at, unit = "month")) %>%
  group_by(month, usertype) %>% # Group by usertype
  summarise(trip_count = n(), .groups = "drop")

# Create bar graphics
ggplot(two_tables, aes(x = month, y = trip_count, fill = usertype,)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = comma, limits = c(0, 180000)) +
  labs(
    title = "Monthly Trips by User Type",
    x = "Month",
    y = "Number of Trips",
    fill = "User Type"
  ) +
  theme_minimal()





  



