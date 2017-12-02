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
	mkdir -p "$(cache_directory)" "$(import_directory)"
	chmod a+w "$(cache_directory)"
	chmod a+w "$(import_directory)"
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
		-p 0.0.0.0:3142:3142 \
		--restart=always \
		--volume "$(cache_directory)":/var/cache/apt-cacher-ng \
		--volume "$(import_directory)":/var/cache/apt-cacher-ng/_import \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--name hoardercache \
		-t base-apt-cache

get-pw:
	docker exec -t hoardercache cat /etc/apt-cacher-ng/security.conf | sed 's|AdminAuth: acng:||'

launcher:
	@echo "#! /bin/bash" | tee /bin/launcher.sh
	@echo "chmod 777 /var/cache/apt-cacher-ng" | tee -a /bin/launcher.sh
	@echo "/etc/init.d/apt-cacher-ng start" | tee -a /bin/launcher.sh
	@echo "tail -f /var/log/apt-cacher-ng/*" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

online:
	docker exec hoardercache sed -i 's|offlinemode:1|offlinemode:0|g'
	docker exec hoardercache /etc/init.d/apt-cacher-ng restart

offline:
	docker exec hoardercache sed -i 's|offlinemode:0|offlinemode:1|g'
	docker exec hoardercache /etc/init.d/apt-cacher-ng restart

clobber:
	docker system prune -f; \
	docker rm -f base-apt-cache; \
	docker rmi -f hoardercache; \
	true

clobber-all: clobber addon-clobber

curljob:
	\curl -u acng:"$(shell docker exec -t hoardercache cat /etc/apt-cacher-ng/security.conf | sed 's|AdminAuth: acng:||')" \
	  'http://192.168.1.98:3142/acng-report.html?abortOnErrors=aOe&doImport=Start+Import&calcSize=cs&asNeeded=an'

install-curljob:
	echo "#! /usr/bin/env sh" | sudo tee /usr/local/bin/scheduled-cacher-import
	echo "pw=\$$(docker exec -t hoardercache cat /etc/apt-cacher-ng/security.conf | sed 's|AdminAuth: acng:||')" | sudo tee -a /usr/local/bin/scheduled-cacher-import
	echo "echo \"$pw\"" | sudo tee -a /usr/local/bin/scheduled-cacher-import
	echo "curl -u acng:\"\$$(docker exec -t hoardercache cat /etc/apt-cacher-ng/security.conf | sed 's|AdminAuth: acng:||')\" \\" | sudo tee -a /usr/local/bin/scheduled-cacher-import
	echo "  'http://192.168.1.98:3142/acng-report.html?abortOnErrors=aOe&doImport=Start+Import&calcSize=cs&asNeeded=an'" | sudo tee -a /usr/local/bin/scheduled-cacher-import
	echo "" | sudo tee -a /usr/local/bin/scheduled-cacher-import
	sudo chmod +x /usr/local/bin/scheduled-cacher-import
	crontab -l | { cat; echo "15 * * * * scheduled-cacher-import"; } | crontab -


