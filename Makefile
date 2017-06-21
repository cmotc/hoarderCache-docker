dummy:

push:
	gpg --batch --yes --clear-sign -u "$(SIGNING_KEY)" \
		README.md
	git commit -am "$(DEV_MESSAGE)"
	git push github

update:
	git pull
	make build

build:
	docker build -t hoarder-cache .

enter:
	docker run -i -t hoarder-cache bash

launcher:
	echo "#! /usr/bin/env bash" | tee /usr/sbin/launcher.sh
	echo "/usr/sbin/apt-cacher-ng -i -c /etc/apt-cacher-ng &" | tee -a /usr/sbin/launcher.sh
	echo "/usr/sbin/cron" | tee -a /usr/sbin/launcher.sh
	chmod a+x /usr/sbin/launcher.sh

run:
	nohup docker run -p 3124:3124 -t hoarder-cache launcher.sh 2>cacher.err 1>cacher.log &

