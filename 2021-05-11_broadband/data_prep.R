library(dplyr)
library(crosstalk)

## Get the dater
broadband <- tidytuesdayR::tt_load('2021-05-11')

# broadband usage by zip code
d <- broadband$broadband_zip
d <- (d[d$ST == 'OR',])
d$zip <- as.integer(d$`POSTAL CODE`)

# zip code level income data from: https://www.psc.isr.umich.edu/dis/census/Features/tract2zip/
income <- read.csv('data/income_zip.csv')

d <- merge(d, income, by.x = "zip", by.y = 'Zip')

d2 <- d %>%
  mutate(Median = as.numeric(gsub(",", "", Median))) %>%
  mutate(Mean = as.numeric(gsub(",", "", Mean))) %>%
  mutate(Pop = as.numeric(gsub(",", "", Pop)))

# Download zip code level shapefile from TIGRIS
geo <- zctas(cb = TRUE, starts_with = as.character(d2$zip)) %>%
  mutate(zip = as.integer(GEOID10)) %>%
  sf::st_transform(4326)

# join zip boundaries and broadband data 
d3 <- geo_join(geo, d2, by_sp = "zip", by_df = "zip", how = "left")

# spatial points dataframe for map
bb_sp <- d3 %>%
  select(zip, ST, `COUNTY NAME`, `BROADBAND USAGE`, Median, Pop, geometry) #%>%
  #SharedData$new(group = "broadband")
saveRDS(bb_sp, file = "data/bb_sp.rds")

# A regular data frame (without coordinates) for the table and plots.
# Use the same group name as the map data.
bb_df <- as_tibble(d3) %>%
  select(zip, ST, `COUNTY NAME`, `BROADBAND USAGE`, Median, Pop) #%>%
  #SharedData$new(group = "broadband")
saveRDS(bb_df, file = "data/bb_df.rds")

