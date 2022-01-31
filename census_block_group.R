#!/usr/local/bin/Rscript

library(dht)
dht::greeting(geomarker_name = 'census_block_group',
              version = '0.4.2',
              description = 'adds census block group or tract identifiers to geocoded addresses')

dht::qlibrary(dplyr)
dht::qlibrary(tidyr)
dht::qlibrary(sf)

doc <- '
Usage:
  census_block_group.R <filename> <census_year>
'

opt <- docopt::docopt(doc)
## for interactive testing
## opt <- docopt::docopt(doc, args = c('test/my_address_file_geocoded.csv', '2000', 'tracts'))

if(! opt$census_year %in% c('2020', '2010', '2000', '1990', '1980', '1970')) {
  cli::cli_alert_danger('Available census geographies include years 1970, 1980, 1990, 2000, 2010, and 2020.')
  stop()
}

if(opt$census_year %in% c('1980', '1970')) {
  cli::cli_alert_warning('Block groups are not available for the selected year. Only tract identifiers will be returned.')
}

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

d <- st_transform(d, 5072)

message('\nloading census shape files...')

if (opt$census_year %in% c('1980', '1970')) {
  geography <- readRDS(file=paste0("/app/tracts_", opt$census_year, "_5072.rds"))
} else {
  geography <- readRDS(file=paste0("/app/block_groups_", opt$census_year, "_5072.rds"))
}

message('\nfinding containing geography for each point...')
d <- sf::st_join(d, geography, left = FALSE, largest = TRUE)

if(! opt$census_year %in% c('1980', '1970')) {
  d <- d %>%
    mutate_at(vars(starts_with(glue::glue('fips_block_group_id_{opt$census_year}'))),
              list(fips_tract_id = ~stringr::str_sub(.x, 1, 11)))

  names(d)[ncol(d)] <- glue::glue('{names(d)[ncol(d)]}_{opt$census_year}')
}

## merge back on .row after unnesting .rows into .row
d <- d %>%
  unnest(cols = c(.rows)) %>%
  st_drop_geometry()

out <- left_join(raw_data, d, by = '.row') %>% select(-.row)

out_file_name <- paste0(tools::file_path_sans_ext(opt$filename), '_census_block_group_', opt$census_year, '.csv')
readr::write_csv(out, out_file_name)
message('\nFINISHED! output written to ', out_file_name)
