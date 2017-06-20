dummy:

update:
	git pull
	make build

build:
	docker build -t hoarder-cache .

enter:
	docker run -i -t hoarder-cache bash

run:
	nohup docker run -t hoarder-cache /sbin/init 2>1 &

sysv-init:
	/sbin/init
