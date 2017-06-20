dummy:

update:
	git pull
	make build

build:
	docker build -t hoarder-cache .

enter:
	docker run -i -t hoarder-cache bash

run:
	nohup docker run -p 3124:3124 -t hoarder-cache make sysv-init 2>1 &

sysv-init:
	/sbin/init
