# Tidy Tuesday Week 49 2020
# Elliot Hohn @elhohn
# Toronto shelters dataset

# Load packages
library(tidyverse)
library(ggmap)
library(sf)
library(mapview)
library(maps)
library(ggthemes)
library(gganimate)


# Get the Data
# Read in with tidytuesdayR package 
tuesdata <- tidytuesdayR::tt_load('2020-12-01')
shelters <- tuesdata$shelters

# or once the geocoding section below has been run just load the updated csv
#shelters <- read.csv('data/shelters_geocoded.csv')

# add new column that is the concatenated address, city, prov for ggmap
shelters$full_address <- paste0(shelters$shelter_address, ", ", shelters$shelter_city,
                       " ", shelters$shelter_province, " ", shelters$shelter_postal_code)

# Initialize the data frame
geocoded <- data.frame(stringsAsFactors = FALSE)

# Loop through the addresses to get the latitude and longitude of each address and add it to the
# origAddress data frame in new columns lat and lon
# Note: must rester google API key for this to work! (see ?register_google for details)
for(i in 1:nrow(shelters)) {
  result <- geocode(shelters$full_address[i], output = "more", source = "google")
  shelters$lon[i] <- as.numeric(result[1])
  shelters$lat[i] <- as.numeric(result[2])
  #shelters$geoAddress[i] <- as.character(result[5])
}

# check for nas
sum(is.na(shelters$lat))
sum(is.na(shelters$lon))

# inspect the nas
nas <- shelters[is.na(shelters$lat),]

# try geocoding again with some additional info added
for(i in 1:50) {
  print(paste("finding", nas$shelter_name[i]))
  result <- geocode(shelters$full_address[i], output = "more", source = "google")
  print(paste("result:", result))
}

# seems to be working, so run the geocoding again for just the NAs in shelters
for(i in 1:nrow(shelters)) {
  if (is.na(shelters$lat[i])) {
    print(i)
    print(paste("finding", shelters$shelter_name[i]))
    result <- geocode(shelters$full_address[i], output = "more", source = "google")
    shelters$lon[i] <- as.numeric(result[1])
    shelters$lat[i] <- as.numeric(result[2])
  } else next
}

# check again for nas. rinse and repeat as necessary until nas are all gone.
# check for nas
sum(is.na(shelters$lat))
sum(is.na(shelters$lon))

# once it looks good transform into sf object then write this to csv
locations_sf <- st_as_sf(shelters, coords = c("lon", "lat"), crs = 4326)
write.csv(shelters, "data/shelters_geocoded.csv")

# map it with mapview to explore
#mapview(locations_sf) #too big and clunky

# get bounding box
box <- make_bbox(shelters$lon, shelters$lat)

# grab tiles from google - commented out because also not a good option
# base <- get_map(location = box, source = "stamen", maptype = "watercolor")
# 
# # plot the points and color them by sector
# ggmap(base) + 
#   geom_point(data = shelters, mapping = aes(x = lon, y = lat, color = sector))

# start with a basic plot
# since this will eventually be an animated plot showing one point per shelter at a time
shelters <- shelters[!is.na(shelters$occupancy) & !is.na(shelters$capacity) & shelters$capacity != 0,]
shelters$percent_capacity <- shelters$occupancy / shelters$capacity * 100
shelters <- shelters[shelters$percent_capacity < 150,]
one_day <- shelters[as.character(shelters$occupancy_date) == '2018-02-20',]

map <- ggplot() +
  geom_point(aes(x = lon, y = lat, size = capacity),
             data = one_day, 
             colour = 'purple', alpha = .5) +
  scale_size_continuous(range = c(1, 12), 
                        breaks = c(250, 500, 750, 1000)) +
  labs(size = 'Capacity')
map

# try to plot density - use a single point from each shelter location at first
ggplot(one_day, aes(x = lon, y = lat)) + 
  coord_equal() + 
  xlab('Longitude') + 
  ylab('Latitude') + 
  stat_density2d(aes(fill = ..level..), alpha = .5,
                 h = .03, n = 300,
                 geom = "polygon", data = one_day) + 
  scale_fill_viridis_c() + 
  theme(legend.position = 'none')

# try to create an animated map of points
shelters$occupancy_date <- as.Date(shelters$occupancy_date)

map <- ggplot(shelters, aes(x = lon, y = lat)) + 
  coord_equal() + 
  xlab('Longitude') + 
  ylab('Latitude') + 
  stat_density2d(aes(fill = ..level..), alpha = .5,
                 h = .03, n = 300,
                 geom = "polygon", data = shelters) + 
  scale_fill_viridis_c() + 
  theme(legend.position = 'none') +
  labs(size = '% Capacity',
       title = "Date: {frame_time}") +
  transition_time(occupancy_date) +
  ease_aes("linear")

animate(map, renderer = gifski_renderer())
