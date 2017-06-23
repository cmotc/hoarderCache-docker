dummy:

push:
	gpg --batch --yes --clear-sign -u "$(SIGNING_KEY)" \
		README.md
	git add .
	git commit -am "$(DEV_MESSAGE)"
	git push

update:
	git pull

update-build:
	make update
	make build

update-all:
	git pull
	make all

build:
	docker build -t hoarder-cache .

all:
	make stage-zero-build
	make stage-one-build
	make stage-two-build
	make stage-three-build
	make stage-four-build

stage-zero-build:
	cd base-apt-cache; \
		docker build -t base-apt-cache .

stage-one-build:
	cd fyrix-apt-cache; \
		docker build -t fyrix-apt-cache .

stage-two-build:
	cd hoarder-apt-cache; \
		docker build -t hoarder-apt-cache .

stage-three-build:
	cd hoarder-apt-cache-source; \
		docker build -t hoarder-apt-cache-source .

stage-four-build:
	cd hoarder-apt-cache-source; \
		docker build -t hoarder-apt-cache-source-startup .

enter:
	docker run -i -t hoarder-apt-cache-source-startup bash

launcher:
	echo "#! /usr/bin/env bash" | tee launcher.sh
	echo "/usr/sbin/apt-cacher-ng -i -c /etc/apt-cacher-ng " | tee -a launcher.sh
	echo "/usr/sbin/cron " | tee -a launcher.sh
	echo "" | tee -a launcher.sh
	chmod a+x launcher.sh

run:
	docker run -p 3142:3142 -t hoarder-apt-cache-source ./launcher.sh
