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
	make all

update-all:
	git pull
	make all

all:
	make stage-zero-build

stage-zero-build:
	docker build --force-rm -t base-apt-cache .

enter:
	docker exec -i -t fyrix-hoarder-cache bash

run:
	docker run -d --rm \
		-h apthoarder \
		-p 3142:3142 \
		--volume cache:/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name fyrix-hoarder-cache \
		-t base-apt-cache

run-daemon:
	docker run -d \
		-h apthoarder \
		-p 3142:3142 \
		--restart=always \
		--volume cache:/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name fyrix-hoarder-cache \
		-t base-apt-cache

run-bridge:
	docker run -d \
		-h apthoarder \
		-p 3142:3142 \
		--restart=always \
		--volume cache:/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name fyrix-hoarder-cache-bridge \
		-t base-apt-cache

launcher:
	@echo "#! /bin/bash" | tee /bin/launcher.sh
	@echo "chmod 777 /var/cache/apt-cacher-ng" | tee -a /bin/launcher.sh
	@echo "/etc/init.d/apt-cacher-ng start" | tee -a /bin/launcher.sh
	@echo "tail -f /var/log/apt-cacher-ng/*" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

clobber:
	docker system prune -f; \
	docker rm -f base-apt-cache; \
	docker rmi -f fyrix-hoarder-cache; \
	true
