library(reactable)
library(leaflet)
library(tigris)

options(tigris_use_cache = TRUE)


# Load data (prepped with data_prep.R)
bb_df <- readRDS('data/bb_df.Rds')
bb_sp <- readRDS('data/bb_sp.Rds')

options(reactable.theme = reactableTheme(
  color = "hsl(233, 9%, 87%)",
  backgroundColor = "#121212",
  borderColor = "#121212",
  stripedColor = "hsl(233, 12%, 22%)",
  highlightColor = "hsl(233, 12%, 24%)",
  inputStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  selectStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  pageButtonHoverStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  pageButtonActiveStyle = list(backgroundColor = "hsl(233, 9%, 28%)")
))

pal <- colorNumeric(
  palette = "magma",
  domain = bb_sp$`BROADBAND USAGE`)

# create labels for zipcodes
labels <- paste0("Zip Code: ",
                 bb_sp$zip, "<br/>",
                 "Broadband Usage: ",
                 bb_sp$`BROADBAND USAGE`) %>%
  lapply(htmltools::HTML)