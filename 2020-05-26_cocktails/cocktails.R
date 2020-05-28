library(tidyverse)

# Get the Data
cocktails <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-26/cocktails.csv')
#boston_cocktails <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-26/boston_cocktails.csv')

# filter to only drinks with Bailey's (creamy)
baileys <- cocktails %>% 
  group_by(drink) %>%
  filter(any(ingredient == "Bailey's irish cream"))

# clean it up!
# measure columns looks like a shit show
print(unique(baileys$measure))

# start by adding a column that has the volume of the vessel it's served in
# map the glass column to an assumed volume
print(unique(baileys$glass))

baileys <- baileys %>%
  mutate(
    vol_oz = case_when(
      glass == 'Shot glass' ~ 1.5,
      glass == 'Collins Glass' ~ 14,
      glass == 'Collins glass' ~ 14,
      glass == 'Cocktail glass' ~ 6,
      glass == 'Beer mug' ~ 16,
      glass == 'Irish coffee cup' ~ 8,
      glass == 'Highball glass' ~ 12,
      glass == 'Highball Glass' ~ 12,
      glass == 'Old-fashioned glass' ~ 12,
      glass == 'Coffee Mug' ~ 8
    )
  )

table(baileys$vol_oz)
table(baileys$glass)

# start by creating a new column for "parts" that can then be summed within
# drinks and combined with drink volume to determine component volumes
baileys$parts <- ifelse(grepl('parts', baileys$measure, ignore.case = T), 
                        substr(baileys$measure, 1, nchar(baileys$measure) - 6),
                  ifelse(grepl("part", baileys$measure, ignore.case = T), 
                         substr(baileys$measure, 1, nchar(baileys$measure) - 5), ''))








