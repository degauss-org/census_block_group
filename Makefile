.PHONY: build test shell clean

build:
	docker build -t census_block_group .

test:
	docker run --rm -v "${PWD}/test":/tmp census_block_group my_address_file_geocoded.csv 2020
	docker run --rm -v "${PWD}/test":/tmp census_block_group my_address_file_geocoded.csv 2010
	docker run --rm -v "${PWD}/test":/tmp census_block_group my_address_file_geocoded.csv 2000
	docker run --rm -v "${PWD}/test":/tmp census_block_group my_address_file_geocoded.csv 1990
	docker run --rm -v "${PWD}/test":/tmp census_block_group my_address_file_geocoded.csv 1980
	docker run --rm -v "${PWD}/test":/tmp census_block_group my_address_file_geocoded.csv 1970

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}/test":/tmp census_block_group

clean:
	docker system prune -f
