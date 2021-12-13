FROM rocker/r-ver:4.0.0

RUN R --quiet -e "install.packages('remotes', repos = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest')"
# make sure version matches what is used in the project: packageVersion('renv')
ENV RENV_VERSION 0.14.0
RUN R --quiet -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /app

RUN apt-get update \
  && apt-get install -yqq --no-install-recommends \
  libgdal-dev \
  libgeos-dev \
  libudunits2-dev \
  libproj-dev \
  libssl-dev \
  && apt-get clean

COPY renv.lock .
RUN R --quiet -e "renv::restore(repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"

ADD https://geomarker.s3.us-east-2.amazonaws.com/geometries/block_groups_2020_5072.rds .
ADD https://geomarker.s3.us-east-2.amazonaws.com/geometries/block_groups_2010_5072.rds .
ADD https://geomarker.s3.us-east-2.amazonaws.com/geometries/block_groups_2000_5072.rds .
ADD https://geomarker.s3.us-east-2.amazonaws.com/geometries/block_groups_1990_5072.rds .
ADD https://geomarker.s3.us-east-2.amazonaws.com/geometries/tracts_1980_5072.rds .
ADD https://geomarker.s3.us-east-2.amazonaws.com/geometries/tracts_1970_5072.rds .
COPY census_block_group.R .

WORKDIR /tmp

ENTRYPOINT ["/app/census_block_group.R"]
