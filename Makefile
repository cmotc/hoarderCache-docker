dummy:

update:
	git pull
	make build

build:
	docker build -t hoarder-cache .

enter:
	docker run -i -t hoarder-cache bash

run:
	nohup docker run -p 3124:3124 -t hoarder-cache bash -c 'service apt-cacher-ng start && service unattended-upgrades start' 2>cacher.err 1>cacher.log &

sysv-init:
	service apt-cacher-ng start && service unattended-upgrades start
