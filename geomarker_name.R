#!/usr/local/bin/Rscript

library(dplyr)
library(tidyr)
library(sf)

doc <- '
Usage:
  geomarker_name.R <filename>
'

opt <- docopt::docopt(doc)
## for interactive testing
## opt <- docopt::docopt(doc, args = 'test/my_address_file_geocoded.csv')

message('\nreading input file...')
raw_data <- readr::read_csv(opt$filename)

## prepare data for calculations
raw_data$.row <- seq_len(nrow(raw_data))

d <-
  raw_data %>%
  select(.row, lat, lon) %>%
  na.omit() %>%
  group_by(lat, lon) %>%
  nest(.rows = c(.row)) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326)

## function for creating a geomarker based on a single sf point
get_geomarker_name <- function(query_point) {
  query_point <- st_sfc(query_point, crs = 4326)

  # ...

}

## apply this function across all points
message('\nfinding closest schwartz grid site index for each point...')
d <- d %>%
  mutate(geomarker_name = mappp::mappp(d$geometry, get_geomarker_name,
                                       parallel = FALSE,
                                       quiet = FALSE))

## merge back on .row after unnesting .rows into .row
d <- d %>%
  unnest(cols = c(.rows)) %>%
  st_drop_geometry()

out <- left_join(raw_data, d, by = '.row') %>% select(-.row)

out_file_name <- paste0(tools::file_path_sans_ext(opt$filename), '_geomarker_name.csv')
readr::write_csv(out, out_file_name)
message('\nFINISHED! output written to ', out_file_name)
