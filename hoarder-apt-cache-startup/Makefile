dummy:

launcher:
	echo "#! /usr/bin/env bash" | tee /bin/launcher.sh
	echo "/sbin/init " | tee -a /bin/launcher.sh
	chmod a+x /bin/launcher.sh

run:
	docker run -i -p 3142:3142 -t hoarder-apt-cache-source-startup launcher.sh
