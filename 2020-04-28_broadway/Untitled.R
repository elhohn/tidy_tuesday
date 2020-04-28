## Tidy Tuesday - 2020-04-28
## Broadway Weekly Grosses
## Author: elliot hohn

library(tidyverse)
library(tidytuesdayR)
#library(lubridate)
#library(rvest)

# Get the Data
grosses <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/grosses.csv')
synopses <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/synopses.csv')
cpi <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/cpi.csv')
pre_1985_starts <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/pre-1985-starts.csv')

summary(grosses)

# simple scatter plot of weekly gross versus time
p1 <- ggplot(grosses, aes(x = week_ending, y = weekly_gross, color = show)) + 
  geom_point(size = 5, alpha = 0.1) + theme(legend.position = 'none')
p1

# jitter plot of theater and pct capacity
p2 <- ggplot(grosses, aes(x = theatre, y = pct_capacity, color = theatre)) +
  geom_jitter() + theme(legend.position = 'none') +
  scale_color_viridis_d()
p2
