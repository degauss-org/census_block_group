# census_block_group <a href='https://degauss-org.github.io/DeGAUSS/'><img src='DeGAUSS_hex.png' align="right" height="138.5" /></a>

> A docker container for assigning census block group id to geocoded addresses.

[![Docker Build Status](https://img.shields.io/docker/automated/degauss/census_block_group)](https://hub.docker.com/repository/docker/degauss/census_block_group/tags)
[![GitHub release (latest by date)](https://img.shields.io/github/release/degauss-org/census_block_group.svg)](https://github.com/degauss-org/census_block_group/releases)

## DeGAUSS example call

```sh
docker run --rm -v $PWD:/tmp degauss/census_block_group:0.3 my_address_file_geocoded.csv 2010
```

* The first argument (`my_address_file_geocoded.csv`) is the name of your geocoded csv file
* The second argument (`2010`) is the year for assignment of block groups. Currently supported years include 1990, 2000, 2010, and 2020.

## geomarker data

- block group shapefiles for 1990, 2000, and 2010 were obtained from [NHGIS](https://www.nhgis.org/) and transformed using the `00_make_block_group_shp.R` file in this repository.

- block group shapefiles for 2020 were obtained directly from the [U.S. Census Bureau](https://www.census.gov/geographies/mapping-files/2020/geo/tiger-line-file.html) via `get_2020_block_groups.R`. 

- The transformed block group shapefiles are stored at 

    + [`s3://geomarker/geometries/block_groups_2020_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_2020_5072.rds)

    + [`s3://geomarker/geometries/block_groups_2010_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_2010_5072.rds)

    + [`s3://geomarker/geometries/block_groups_2000_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_2000_5072.rds)
    
        + [`s3://geomarker/geometries/block_groups_1990_5072.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/block_groups_1990_5072.rds)

## DeGAUSS details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS README](https://github.com/degauss-org/DeGAUSS).

### references

Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. IPUMS National Historical Geographic Information System: Version 15.0 [dataset]. Minneapolis, MN: IPUMS. 2020. http://doi.org/10.18128/D050.V15.0

