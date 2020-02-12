library(tidyverse)
library(sf)

blk_grps_sf <- st_read("./nhgis0002_shape/nhgis0002_shapefile_tl2010_us_blck_grp_2010/US_blck_grp_2010.shp")

blk_grps_sf <- st_transform(blk_grps_sf, crs=5072) %>% 
  dplyr::select(fips_block_group_id = GEOID10,
                geometry)

saveRDS(blk_grps_sf, "NHGIS_US_block_groups_5072_simplefeatures.rds")

