FROM rocker/r-ver:4.4.1

# DeGAUSS container metadata
ENV degauss_name="census_block_group"
ENV degauss_version="1.0.1"
ENV degauss_description="census block group and tract"
ENV degauss_argument="census year [default: 2010]"

# add OCI labels based on environment variables too
LABEL "org.degauss.name"="${degauss_name}"
LABEL "org.degauss.version"="${degauss_version}"
LABEL "org.degauss.description"="${degauss_description}"
LABEL "org.degauss.argument"="${degauss_argument}"

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
    libgdal-dev \
    libgeos-dev \
    libudunits2-dev \
    libproj-dev \
    && apt-get clean

RUN R --quiet -e "install.packages('remotes', repo = c(CRAN = 'https://packagemanager.posit.co/cran/latest'))"

RUN R --quiet -e "remotes::install_github('rstudio/renv@v1.0.7')"

WORKDIR /app

COPY renv.lock .

RUN R --quiet -e "renv::restore(repos = c(CRAN = 'https://packagemanager.posit.co/cran/latest'))"

ADD https://github.com/degauss-org/census_block_group/releases/download/1.0.0/block_groups_2020_5072.rds .
ADD https://github.com/degauss-org/census_block_group/releases/download/1.0.0/block_groups_2010_5072.rds .
ADD https://github.com/degauss-org/census_block_group/releases/download/1.0.0//block_groups_2000_5072.rds .
ADD https://github.com/degauss-org/census_block_group/releases/download/1.0.0/block_groups_1990_5072.rds .
ADD https://github.com/degauss-org/census_block_group/releases/download/1.0.0/tracts_1980_5072.rds .
ADD https://github.com/degauss-org/census_block_group/releases/download/1.0.0/tracts_1970_5072.rds .
COPY entrypoint.R .

WORKDIR /tmp

ENTRYPOINT ["/app/entrypoint.R"]
