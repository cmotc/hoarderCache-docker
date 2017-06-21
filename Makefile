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

stage-zero-build:
	cd base-apt-cache; \
		docker build -t base-apt-cache .

stage-one-build:
	cd fyric-apt-cache; \
		docker build -t fyrix-apt-cache .

stage-two-build:
	cd hoarder-apt-cache; \
		docker build -t hoarder-apt-cache .

stage-three-build:
	cd hoarder-apt-cache-source; \
		docker build -t hoarder-apt-cache-source .

enter:
	docker run -i -t hoarder-cache bash

launcher:
	echo "#! /usr/bin/env bash" | tee /usr/sbin/launcher.sh
	echo "/usr/sbin/apt-cacher-ng -i -c /etc/apt-cacher-ng &" | tee -a /usr/sbin/launcher.sh
	echo "/usr/sbin/cron" | tee -a /usr/sbin/launcher.sh
	chmod a+x /usr/sbin/launcher.sh

run:
	docker run -p 3124:3124 -t hoarder-cache /usr/sbin/launcher.sh 2>cacher.err 1>cacher.log &
