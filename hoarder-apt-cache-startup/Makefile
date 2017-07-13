dummy:

launcher:
	echo "#! /bin/bash" | tee /bin/launcher.sh
	echo "    apt-cacher-ng" | tee -a /bin/launcher.sh
	echo "    cron" | tee -a /bin/launcher.sh
	echo "    sleep 12000" | tee -a /bin/launcher.sh
	echo "" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

safer-launcher:
	echo "#! /bin/bash" | tee /bin/launcher.sh
	echo "while true; do" | tee -a /bin/launcher.sh
	echo "    apt-cacher-ng" | tee -a /bin/launcher.sh
	echo "    cron" | tee -a /bin/launcher.sh
	echo "    sleep 12000" | tee -a /bin/launcher.sh
	echo "done" | tee -a /bin/launcher.sh
	echo "" | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh
