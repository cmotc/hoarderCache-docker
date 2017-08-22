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

stage-zero-build:
	docker build --force-rm -t base-apt-cache .

enter:
	docker run -i -t base-apt-cache bash

run:
	docker run -h aptcacher \
		-p 3142:3142 \
		--volume cache:/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name fyrix-hoarder-cache \
		-t base-apt-cache

run-daemon:
	docker run -d --rm \
		-h aptcacher \
		-p 3142:3142 \
		--volume cache:/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name fyrix-hoarder-cache-daemon \
		-t base-apt-cache

run-bridge:
	docker run -d \
		-h aptcacher \
		-p 3142:3142 \
		--restart=always \
		--volume cache:/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name fyrix-hoarder-cache-bridge \
		-t base-apt-cache

launcher:
	echo "#! /bin/bash" | tee /bin/launcher.sh
	echo "apt-cacher-ng -c /etc/apt-cacher-ng/" | tee -a /bin/launcher.sh
	echo "while true; do" | tee -a /bin/launcher.sh
	echo "    sleep 12000" | tee -a /bin/launcher.sh
	echo "done" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh
