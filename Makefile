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
	cd hoarder-apt-cache-startup; \
		docker build -t hoarder-apt-cache-source-startup .

enter:
	docker run -i -t hoarder-apt-cache-source-startup bash

run:
	docker run -i \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-h aptcacher \
		--network=peer-vpn-network \
		--ip=192.168.3.101 \
		-p 3142:3142 \
		--name fyrix-hoarder-cache \
		-t hoarder-apt-cache-source-startup launcher.sh

run-bridge:
	docker run -i \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-h aptcacher \
		--network=bridge \
		-p 3142:3142 \
		--name fyrix-hoarder-cache-bridge \
		-t hoarder-apt-cache-source-startup launcher.sh
