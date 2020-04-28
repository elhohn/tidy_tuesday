## Tidy Tuesday - 2020-04-28
## Broadway Weekly Grosses
## Author: elliot hohn

library(tidyverse)
library(tidytuesdayR)
library(randomcoloR)
library(lubridate)
#devtools::install_github('thomasp85/gganimate')
library(gganimate)

# Get the Data
grosses <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/grosses.csv')
synopses <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/synopses.csv')
cpi <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/cpi.csv')
pre_1985_starts <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/pre-1985-starts.csv')

summary(grosses)

# simple scatter plot of weekly gross versus time
p1 <- ggplot(grosses, aes(x = week_ending, y = weekly_gross, color = show)) + 
  geom_point(size = 5, alpha = 0.1) + 
  scale_color_viridis_d() +
  theme(legend.position = 'none',
        axis.text.x = element_text(angle = 90, hjust = 1))
p1

# jitter plot of theater and pct capacity
p2 <- ggplot(grosses, aes(x = theatre, y = pct_capacity, color = theatre)) +
  geom_jitter() + 
  scale_color_viridis_d() +
  theme(legend.position = 'none',
        axis.text.x = element_text(angle = 90, hjust = 1))
p2

# heat map?
p3 <- ggplot(grosses[1:300,], aes(week_number, show)) +
  geom_tile(aes(fill = weekly_gross), color = 'white') +
  scale_fill_viridis_c(option = "C") +
  theme(legend.position = 'none') +
  theme_minimal()
p3

# plan: show top 10 theater rankings, based on grosses, across time
# group by week and rank by gross, descending
grosses <- grosses %>%
  group_by(week_ending) %>%
  arrange(week_ending, weekly_gross) %>%
  mutate(weekly_rank = rank(desc(weekly_gross)))

# create new dataframe that is only top 10s
top_tens <- grosses %>%
  filter(weekly_rank <= 10)

# count how many times each theater is in the top 10
theater_counts <- top_tens %>%
  group_by(theatre) %>%
  mutate(avg_capacity = round(mean(seats_in_theatre),0)) %>%
  group_by(theatre, avg_capacity) %>%
  tally()

# plot top 10 count vs capacity
ggplot(theater_counts, aes(avg_capacity, n, size = avg_capacity, color = theatre)) +
  geom_point()

# animated plot?
top_tens_last20yrs <- top_tens %>% filter(year(week_ending) >= 2000)
ggplot(top_tens_last20yrs, aes(x = week_ending, y = weekly_rank, group = theatre,
                               color = theatre)) +
  #geom_line() +
  geom_segment(aes(xend = max(top_tens_last20yrs$week_ending), yend = weekly_rank), linetype = 2, colour = 'grey') +
  geom_point(size = 2) +
  geom_text(aes(x = max(top_tens_last20yrs$week_ending), label = theatre), hjust = 0) +
  coord_cartesian(clip = 'off') +
  transition_reveal(week_ending) +
  theme_minimal() +
  theme(plot.margin = margin(5.5, 60, 5.5, 5.5),
        legend.position = 'none')


  



