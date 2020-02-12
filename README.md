# census_block_group <a href='https://degauss-org.github.io/DeGAUSS/'><img src='DeGAUSS_hex.png' align="right" height="138.5" /></a>

> short description of geomarker

[![Docker Build Status](https://img.shields.io/docker/build/degauss/census_block_group)](https://hub.docker.com/repository/docker/degauss/census_block_group/tags)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/degauss-org/census_block_group)](https://github.com/degauss-org/census_block_group/releases)

## DeGAUSS example call

```sh
docker run --rm -v $PWD:/tmp degauss/census_block_group:0.1 my_address_file_geocoded.csv
```

## geomarker data

- block group shapefiles were obtained from [NHGIS](https://www.nhgis.org/) and transformed using the `00_make_block_group_shp.R` file in this repository.
- The transformed block group shapefile is stored at [`s3://geomarker/geometries/NHGIS_US_2010_block_groups_5072_simplefeatures.rds`](https://geomarker.s3.us-east-2.amazonaws.com/geomarker/geometries/NHGIS_US_2010_block_groups_5072_simplefeatures.rds)

## DeGAUSS details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS README](https://github.com/degauss-org/DeGAUSS).

