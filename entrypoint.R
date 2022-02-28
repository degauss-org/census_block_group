#!/usr/local/bin/Rscript

dht::greeting()

## load libraries without messages or warnings
withr::with_message_sink("/dev/null", library(dplyr))
withr::with_message_sink("/dev/null", library(tidyr))
withr::with_message_sink("/dev/null", library(sf))

doc <- "
      Usage:
      entrypoint.R <filename> <census_year>
      "

opt <- docopt::docopt(doc)

## for interactive testing
## opt <- docopt::docopt(doc, args = 'test/my_address_file_geocoded.csv')

if (is.null(opt$census_year)) {
  opt$census_year <- 2010
  cli::cli_alert("No census year provided. Using 2010.")
}

if(! opt$census_year %in% c('2020', '2010', '2000', '1990', '1980', '1970')) {
  cli::cli_alert_danger('Available census geographies include years 1970, 1980, 1990, 2000, 2010, and 2020.')
  stop()
}

if(opt$census_year %in% c('1980', '1970')) {
  cli::cli_alert_warning('Block groups are not available for the selected year. Only tract identifiers will be returned.')
}

message("reading input file...")
d <- dht::read_lat_lon_csv(opt$filename, nest_df = T, sf = T, project_to_crs = 5072)

dht::check_for_column(d$raw_data, "lat", d$raw_data$lat)
dht::check_for_column(d$raw_data, "lon", d$raw_data$lon)

message('loading census shape files...')
if (opt$census_year %in% c('1980', '1970')) {
  geography <- readRDS(file=paste0("/app/tracts_", opt$census_year, "_5072.rds"))
} else {
  geography <- readRDS(file=paste0("/app/block_groups_", opt$census_year, "_5072.rds"))
}

message('finding containing geography for each point...')
d$d <- suppressWarnings( sf::st_join(d$d, geography, left = FALSE, largest = TRUE) )

if(! opt$census_year %in% c('1980', '1970')) {
  d$d <- d$d %>%
    mutate_at(vars(starts_with(glue::glue('fips_block_group_id_{opt$census_year}'))),
              list(fips_tract_id = ~stringr::str_sub(.x, 1, 11)))

  names(d$d)[ncol(d$d)] <- glue::glue('{names(d$d)[ncol(d$d)]}_{opt$census_year}')
}

## merge back on .row after unnesting .rows into .row
dht::write_geomarker_file(d = d$d,
                          raw_data = d$raw_data,
                          filename = opt$filename,
                          argument = opt$census_year)


