dummy:

launcher:
	echo "#! /bin/bash" | tee /bin/launcher.sh
	echo "/sbin/init" | tee -a /bin/launcher.sh
	echo "while true; do" | tee -a /bin/launcher.sh
	echo "    service apt-cacher-ng start" | tee -a /bin/launcher.sh
	echo "    service cron start" | tee -a /bin/launcher.sh
	echo "    service unattended-upgrades start" | tee -a /bin/launcher.sh
	echo "    sleep 12000" | tee -a /bin/launcher.sh
	echo "done" | tee -a /bin/launcher.sh
	echo "" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

run:
	docker run -i -p 3142:3142 -t hoarder-apt-cache-source-startup launcher.sh &
