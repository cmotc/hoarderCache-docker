dummy: .get-addons
	@echo "$(username)"
	@echo "$(password)"
	@echo "$(working_directory)"
	@echo "$(cache_directory)"

include config.mk

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
	make update
	make all
	make restart
	make addon-update

all:
	docker build --build-arg "acng_password=$(password)" \
		--build-arg "CACHING_PROXY=$(proxy_addr)" \
		-t base-apt-cache .
	docker system prune -f

enter:
	docker exec -i -t hoardercache bash

restart:
	docker rm -f hoardercache; \
	make run-daemon

run-daemon:
	docker run -d \
		-h apthoarder \
		-p 3142:3142 \
		--restart=always \
		--volume "$(cache_directory)":/var/cache/apt-cacher-ng \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name hoardercache \
		-t base-apt-cache

get-pw:
	docker exec -t hoardercache cat /etc/apt-cacher-ng/security.conf

launcher:
	@echo "#! /bin/bash" | tee /bin/launcher.sh
	@echo "chmod 777 /var/cache/apt-cacher-ng" | tee -a /bin/launcher.sh
	@echo "/etc/init.d/apt-cacher-ng start" | tee -a /bin/launcher.sh
	@echo "tail -f /var/log/apt-cacher-ng/*" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

clobber:
	docker system prune -f; \
	docker rm -f base-apt-cache; \
	docker rmi -f hoardercache; \
	true

clobber-all: clobber addon-clobber
