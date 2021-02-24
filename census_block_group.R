#!/usr/local/bin/Rscript

dht::greeting(geomarker_name = 'census_block_group',
              version = '0.3',
              description = 'adds census block group numbers to geocoded addresses')

dht::qlibrary(dplyr)
dht::qlibrary(tidyr)
dht::qlibrary(sf)

doc <- '
Usage:
  census_block_group.R <filename> <census_year>
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

d <- st_transform(d, 5072)

message('\nloading block group shape files...')
block_groups <- readRDS(file=paste0("/app/block_groups_", opt$census_year, "_5072.rds"))

message('\nfinding block group for each point...')
d <- sf::st_join(d, block_groups, left = FALSE)

## merge back on .row after unnesting .rows into .row
d <- d %>%
  unnest(cols = c(.rows)) %>%
  st_drop_geometry()

out <- left_join(raw_data, d, by = '.row') %>% select(-.row)

out_file_name <- paste0(tools::file_path_sans_ext(opt$filename), '_census_block_group_', opt$census_year, '.csv')
readr::write_csv(out, out_file_name)
message('\nFINISHED! output written to ', out_file_name)
