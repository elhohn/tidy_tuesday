## Tidy Tuesday - 2020-04-28
## Broadway Weekly Grosses
## Author: elliot hohn

library(tidyverse)
library(tidytuesdayR)
library(randomcoloR)
library(lubridate)
#devtools::install_github('thomasp85/gganimate')
library(gganimate)
library(RColorBrewer)
library(viridis)
library(wesanderson)
extrafont::loadfonts()


# Get the Data
grosses <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/grosses.csv')
synopses <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/synopses.csv')
cpi <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/cpi.csv')
pre_1985_starts <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-28/pre-1985-starts.csv')

summary(grosses)

## Test a few things out
# simple scatter plot of weekly gross versus time
p1 <- ggplot(grosses, aes(x = week_ending, y = weekly_gross, color = show)) + 
  geom_point(size = 2, alpha = 0.1) + 
  scale_color_viridis_d() +
  theme(legend.position = 'none',
        axis.text.x = element_text(angle = 90, hjust = 1))
p1

# heat map?
p3 <- ggplot(grosses[1:300,], aes(week_number, show)) +
  geom_tile(aes(fill = weekly_gross), color = 'white') +
  scale_fill_viridis_c(option = "C") +
  theme(legend.position = 'none') +
  theme_minimal()
p3

# group by week and rank by gross, descending
df <- grosses %>%
  group_by(week_ending) %>%
  arrange(week_ending, weekly_gross) %>%
  mutate(weekly_rank = rank(desc(weekly_gross)))

# create new dataframe that is only top 10s
top_tens <- df %>%
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

#############################################
# final plan: jitter plot of percent capacity for all shows at all theatres
# remove "theatre" or "theatre from the names for plot cleanliness
grosses <- grosses %>%
  mutate(name_clean = ifelse(((substr(theatre, 
                                    (nchar(theatre)+1)-7,
                                    nchar(theatre)) == "Theatre") |
                              (substr(theatre,
                                      (nchar(theatre)+1)-7,
                                      nchar(theatre)) == "Theater")),
                             substr(theatre, 0, (nchar(theatre)+1)-9), theatre))

grosses$name_clean <- ifelse(grosses$name_clean == 'Ford Center for the Performing Arts', "Ford Center", grosses$name_clean)

# remove capacity values > 100 % as well as all 0 %s and 
# find the mean capacity that can be used to re-order items
df <- grosses %>% 
  filter(pct_capacity > 0 & pct_capacity <= 1,
         name_clean != 'Comedy') %>% # this theatre name is confusing and only has a couple shows
  group_by(name_clean) %>% 
  mutate(mean_pct_cap = mean(pct_capacity)) %>%
  ungroup() %>%
  mutate(name_clean = fct_reorder(name_clean, mean_pct_cap))

# create a new color palette
#mycolors <- viridis_pal()(length(unique(grosses$name_clean)))
#mycolors <- brewer.pal(length(unique(grosses$name_clean)),'PRGn')
mycolors <- wes_palette("Zissou1", length(unique(grosses$name_clean)), type = "continuous")
#mycolors <- sample(mycolors) # randomize to it looks more categorical

p2 <- ggplot(df, aes(x = name_clean, y = pct_capacity, color = name_clean)) +
  #geom_boxplot(color = 'gray 45', outlier.color = 'transparent') +
  geom_jitter(alpha = 0.4, stroke = 0) + 
  geom_point(aes(y=mean_pct_cap, x=name_clean), color = 'gray15', alpha = 0.5, stroke = 0.5, shape = 22) +
  scale_color_manual(values = mycolors) +
  #scale_colour_viridis_d(direction = -1, option = "E") +
  #scale_color_brewer('PRGn') +
  scale_y_continuous(labels = scales::percent,
                     expand = c(0, 0),
                     limits = c(.25, 1.02)
                     #breaks=c(0, 0.5,1),
                     #labels=c('Empty',"Half Full", "Sold Out!")
                     ) +
  coord_flip() +
  theme_minimal() +
  # geom_segment(aes(y = .05, yend = .05 , x = "Neil Simon", xend = "John Golden"),
  #              arrow = arrow(length = unit(0.2,"cm")), color = "red") +
  # geom_segment(aes(y = .05, yend = .05 , x = "Bernard B. Jacobs", xend = "Eugene O'Neill"),
  #              arrow = arrow(length = unit(0.2,"cm")), color = "black") +
  # annotate("text", y = .07, x = "Gerald Schoenfeld", label = "More full", color = "Black", size = 3, hjust = -0.1, vjust = .75) +
  # annotate("text", y = .07, x = "Martin Beck", label = "Less full", color = "Red", size = 3, hjust = -0.1, vjust = -.1) +
  labs(y = "Ticket sales, as a percentage of\nthe theater\'s total capacity", 
       title = "How often do Broadway shows sell out?",
       subtitle = paste0("All theaters experience large fluctuations in the number of tickets they sell",
                        " for any given show, relative to the theater's capacity,\nbut some are more full ",
                        "more frequently than others. Each colored point on the plot represents a show, ",
                        "and each black square\nrepresents the average percentage of ticket sales, relative ",
                        "to the theater's capacity, for all shows from 1985 to 2020."),
       caption = "@elliothohn, 2020") +
  theme(plot.background = element_rect(fill = "#F6FCF8"),
        legend.position = 'none',
        axis.title.y = element_blank(),
        axis.title.x = element_text(face = 'bold', vjust = -2),
        axis.text.x = element_text(face='bold'),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        #text = element_text(family = "AvantGarde"),
        plot.title = element_text(size = 22, face = 'bold', margin = margin(b = 10), hjust = 0),
        plot.subtitle = element_text(size = 12, face = 'italic', color = "darkslategrey", margin = margin(b = 10, l = -25)),
        plot.caption = element_text(size = 8, margin = margin(t = 10), color = "grey70", hjust = 0))
    
p2

ggsave("plots/tidytuesday_braodway.png", device = "png", type = "quartz", height = 10, width = 12)


