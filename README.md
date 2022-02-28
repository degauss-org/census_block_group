# census_block_group <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/census_block_group?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/census_block_group/releases)
[![container build status](https://github.com/degauss-org/census_block_group/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/census_block_group/actions/workflows/build-deploy-release.yaml)

## Using

If `my_address_file_geocoded.csv` is a file in the current working directory with coordinate columns named `lat` and `lon`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/census_block_group:0.5.0 my_address_file_geocoded.csv
```

will produce `my_address_file_geocoded_census_block_group_0.5.0_2010.csv` with added columns:

- **`fips_block_group_id_2010`**: identifier for 2010 block group
- **`fips_tract_id_2010`**: identifier for 2010 tract

### Optional Argument

The default census year is 2010 meters, but can be changed by supplying an optional argument to the degauss command. For example,

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/census_block_group:0.5.0 my_address_file_geocoded.csv 1990
```

will produce `my_address_file_geocoded_census_block_group_0.5.0_1990.csv`, with columns called **`fips_block_group_id_1990`** and **`fips_tract_id_1990`**. 

Available years for census block group and census tract identifiers include 1990, 2000, 2010, and 2020. Additionally, tracts identifiers are available for 1970 and 1980.

## Geomarker Methods

- Census block groups are a low level designation within the US Census geographical hierarchy, one degree finer than a census tract. The US Census provides a diagram visualizing the [hierarchy](https://www2.census.gov/geo/pdfs/reference/geodiagram.pdf).
- The first 11 characters in a census block group GEOID indicate the census tract, county and state that the block group lies within. The US Census GEOIDs are constructed in a manner that reflects the geographical hierary of the designated area. By using the segments of the GEOID, it is possible to select data based on area types further up in the hierarchy.

    | Area Type | GEOID | Number of Digits | Example Area | Example GEOID |
    | :-- | :-- | :-- | :-- | :-- |
    | State | State | 2 | Ohio | 39 |
    | County | State + County | 2+3=5 | Hamilton County | 39061 |
    | Census Tract | State + County + Tract | 2+3+6=11 | Tract 32 in Hamilton County | 39061003200 | 
    | Block Group | State + County + Tract +<br /> Block Group | 2+3+6+1=12 | Block Group 1 in Tract 32 | 390610032001 |
    
Due to inconsistencies in the 1970 and 1980 tract identifiers, we concatenated the state FIPS (`NHGISST`), county FIPS (`NGHISCTY`), and tract FIPS (the last 4 or 6 digits of `GISJOIN2`) to construct the full `fips_tract_id`. Since the length of tract FIPS codes varied, we padded all tract FIPS to the maximum 6 digits using zeros. 

## st_census_tract

For spatiotemporal data in which each location is associated with a specified date range, consider using the [`st_census_tract`](https://degauss.org/st_census_tract/) container, which adds census tract identifiers for the appropriate vintage (1970-2020) based on `start_date` and `end_date` for each input location.

## Geomarker Data

- block group shapefiles for 1990, 2000, and 2010, as well as tract shapefiles for 1970 and 1980, were obtained from [NHGIS](https://www.nhgis.org/) and transformed using the `00_make_block_group_shp.R` file in this repository.

- block group shapefiles for 2020 were obtained directly from the [U.S. Census Bureau](https://www.census.gov/geographies/mapping-files/2020/geo/tiger-line-file.html) via `get_2020_block_groups.R`. 

- to avoid any geometry evaluation errors (i.e. self-intersecting rings), we used `sf::st_make_valid` on all tract and block group polygons

- The transformed block group shapefiles are stored at 

    + [`s3://geomarker/geometries/block_groups_2020_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_2020_5072.rds)

    + [`s3://geomarker/geometries/block_groups_2010_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_2010_5072.rds)

    + [`s3://geomarker/geometries/block_groups_2000_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_2000_5072.rds)
    
    + [`s3://geomarker/geometries/block_groups_1990_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_1990_5072.rds)
        
    + [`s3://geomarker/geometries/tracts_1980_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/tracts_1980_5072.rds)
                
    + [`s3://geomarker/geometries/tracts_1970_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/tracts_1970_5072.rds)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).

### References

Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. IPUMS National Historical Geographic Information System: Version 15.0 [dataset]. Minneapolis, MN: IPUMS. 2020. http://doi.org/10.18128/D050.V15.0
