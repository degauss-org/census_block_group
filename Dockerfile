FROM rocker/r-ver:4.0.0

# install a newer-ish version of renv, but the specific version we want will be restored from the renv lockfile
ENV RENV_VERSION 0.8.3-81
RUN R --quiet -e "source('https://install-github.me/rstudio/renv@${RENV_VERSION}')"

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
RUN R --quiet -e "renv::restore()"

COPY block_groups_2020_5072.rds .
COPY block_groups_2010_5072.rds .
COPY block_groups_2000_5072.rds .
COPY block_groups_1990_5072.rds .
COPY census_block_group.R .

WORKDIR /tmp

ENTRYPOINT ["/app/census_block_group.R"]
