dummy:

launcher:
	echo "#! /usr/bin/env bash" | tee /bin/launcher.sh
	echo "#/usr/sbin/apt-cacher-ng -i -c /etc/apt-cacher-ng " | tee -a /bin/launcher.sh
	echo "#/usr/sbin/cron " | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

run:
	docker run -p 3142:3142 -t hoarder-apt-cache-source-startup launcher.sh
